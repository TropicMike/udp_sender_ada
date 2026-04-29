with Ada.Characters.Latin_1;
with Ada.Streams;
with Ada.Exceptions;
with GNAT.Sockets;
with Gnoga.Application.Singleton;
with Gnoga.Gui.Base;
with Gnoga.Gui.Element;
with Gnoga.Gui.Element.Common;
with Gnoga.Gui.Element.Form;
with Gnoga.Gui.View;
with Gnoga.Gui.Window;
with UXStrings;

procedure Udp_Sender is
   use all type Gnoga.String;
   use type Ada.Streams.Stream_Element_Offset;

   LF : constant Character := Ada.Characters.Latin_1.LF;

   Main_Window : Gnoga.Gui.Window.Window_Type;
   Main_View   : Gnoga.Gui.View.View_Type;
   Form        : Gnoga.Gui.Element.Form.Form_Type;

   IP_Label      : Gnoga.Gui.Element.Form.Label_Type;
   IP_Input      : Gnoga.Gui.Element.Form.Text_Type;
   Port_Label    : Gnoga.Gui.Element.Form.Label_Type;
   Port_Input    : Gnoga.Gui.Element.Form.Text_Type;
   Message_Label : Gnoga.Gui.Element.Form.Label_Type;
   Message_Input : Gnoga.Gui.Element.Form.Text_Area_Type;
   Send_Button   : Gnoga.Gui.Element.Common.Button_Type;
   Log_Label_Elm : Gnoga.Gui.Element.Common.Span_Type;
   Log_Area      : Gnoga.Gui.Element.Form.Text_Area_Type;
   Quit_Button   : Gnoga.Gui.Element.Common.Button_Type;

   procedure Append_Log (Text : Gnoga.String) is
      Current : constant Gnoga.String := Log_Area.Value;
   begin
      if Current.Length > 0 then
         Log_Area.Value
           (Value => Current & UXStrings.From_Latin_1 (LF) & Text);
      else
         Log_Area.Value (Value => Text);
      end if;
      Log_Area.Execute ("this.scrollTop = this.scrollHeight;");
   end Append_Log;

   procedure On_Send (Object : in out Gnoga.Gui.Base.Base_Type'Class) is
      pragma Unreferenced (Object);

      IP_Str   : constant String := UXStrings.To_UTF_8 (IP_Input.Value);
      Port_Str : constant String := UXStrings.To_UTF_8 (Port_Input.Value);
      Msg_Str  : constant String := UXStrings.To_UTF_8 (Message_Input.Value);

      Socket  : GNAT.Sockets.Socket_Type;
      Address : GNAT.Sockets.Sock_Addr_Type;
      Last    : Ada.Streams.Stream_Element_Offset;
      Data    : Ada.Streams.Stream_Element_Array (1 .. Msg_Str'Length);
   begin
      if IP_Str'Length = 0 then
         Append_Log ("Error: IP address is empty");
         return;
      end if;
      if Port_Str'Length = 0 then
         Append_Log ("Error: Port is empty");
         return;
      end if;
      if Msg_Str'Length = 0 then
         Append_Log ("Error: Message is empty");
         return;
      end if;

      for I in Msg_Str'Range loop
         Data (Ada.Streams.Stream_Element_Offset
                 (I - Msg_Str'First + 1)) :=
           Ada.Streams.Stream_Element (Character'Pos (Msg_Str (I)));
      end loop;

      Address.Addr := GNAT.Sockets.Inet_Addr (IP_Str);
      Address.Port := GNAT.Sockets.Port_Type'Value (Port_Str);

      GNAT.Sockets.Create_Socket
        (Socket, GNAT.Sockets.Family_Inet, GNAT.Sockets.Socket_Datagram);
      GNAT.Sockets.Send_Socket (Socket, Data, Last, Address);
      GNAT.Sockets.Close_Socket (Socket);

      Append_Log
        ("Sent " & Gnoga.Image (Integer (Last)) & " bytes to " &
         IP_Input.Value & ":" & Port_Input.Value);
   exception
      when E : others =>
         Append_Log
           ("Error: " &
            UXStrings.From_UTF_8 (Ada.Exceptions.Exception_Message (E)));
         begin
            GNAT.Sockets.Close_Socket (Socket);
         exception
            when others => null;
         end;
   end On_Send;

   procedure On_Quit (Object : in out Gnoga.Gui.Base.Base_Type'Class) is
      pragma Unreferenced (Object);
   begin
      Gnoga.Application.Singleton.End_Application;
   end On_Quit;

   Container_CSS : constant Gnoga.String :=
     "max-width:600px; margin:20px auto; background:white; " &
     "padding:24px; border-radius:8px; " &
     "box-shadow:0 2px 8px rgba(0,0,0,0.1); font-family:sans-serif";

   Label_CSS : constant Gnoga.String :=
     "display:block; margin-top:12px; font-weight:bold; " &
     "color:#555; font-size:14px";

   Input_CSS : constant Gnoga.String :=
     "width:100%; padding:8px; margin-top:4px; " &
     "border:1px solid #ccc; border-radius:4px; " &
     "font-size:14px; box-sizing:border-box";

   Textarea_CSS : constant Gnoga.String :=
     Input_CSS & "; font-family:monospace; resize:vertical";

   Send_CSS : constant Gnoga.String :=
     "padding:10px 24px; margin-top:16px; margin-right:8px; " &
     "border:none; border-radius:4px; cursor:pointer; " &
     "font-size:14px; font-weight:bold; background:#4CAF50; color:white";

   Quit_CSS : constant Gnoga.String :=
     "padding:10px 24px; margin-top:16px; " &
     "border:none; border-radius:4px; cursor:pointer; " &
     "font-size:14px; font-weight:bold; background:#f44336; color:white";

begin
   Gnoga.Application.Title (Name => "UDP Sender");
   Gnoga.Application.HTML_On_Close (HTML => "UDP Sender closed.");
   Gnoga.Application.Singleton.Initialize
     (Main_Window => Main_Window,
      Port        => 8_080,
      Verbose     => True);

   Main_Window.Document.Body_Element.Style ("background", "#f5f5f5");

   Main_View.Create (Parent => Main_Window);
   Main_View.Style ("cssText", Container_CSS);

   Main_View.Put_HTML
     (HTML => "<h2 style='margin-top:0;color:#333'>" &
              "UDP Sender</h2>");

   Form.Create (Parent => Main_View);

   IP_Label.Create
     (Form => Form, Label_For => IP_Input,
      Content => "Destination IP Address", Auto_Place => False);
   IP_Label.Style ("cssText", Label_CSS);
   Form.New_Line;
   IP_Input.Create (Form => Form, Size => 40, Value => "127.0.0.1");
   IP_Input.Style ("cssText", Input_CSS);
   IP_Input.Place_Holder (Value => "e.g. 192.168.1.100");

   Port_Label.Create
     (Form => Form, Label_For => Port_Input,
      Content => "Destination Port", Auto_Place => False);
   Port_Label.Style ("cssText", Label_CSS);
   Form.New_Line;
   Port_Input.Create (Form => Form, Size => 10, Value => "5000");
   Port_Input.Style ("cssText", Input_CSS & "; width:120px");
   Port_Input.Place_Holder (Value => "e.g. 5000");

   Message_Label.Create
     (Form => Form, Label_For => Message_Input,
      Content => "Message", Auto_Place => False);
   Message_Label.Style ("cssText", Label_CSS);
   Form.New_Line;
   Message_Input.Create (Form => Form, Columns => 60, Rows => 4);
   Message_Input.Style ("cssText", Textarea_CSS);
   Message_Input.Place_Holder (Value => "Enter text to send via UDP...");

   Form.New_Line;
   Send_Button.Create (Parent => Form, Content => "Send");
   Send_Button.Style ("cssText", Send_CSS);
   Send_Button.On_Click_Handler (Handler => On_Send'Unrestricted_Access);

   Quit_Button.Create (Parent => Form, Content => "Quit");
   Quit_Button.Style ("cssText", Quit_CSS);
   Quit_Button.On_Click_Handler (Handler => On_Quit'Unrestricted_Access);

   Form.New_Line;
   Log_Label_Elm.Create (Parent => Form, Content => "Log");
   Log_Label_Elm.Style ("cssText", Label_CSS);
   Form.New_Line;
   Log_Area.Create (Form => Form, Columns => 60, Rows => 8);
   Log_Area.Style ("cssText", Textarea_CSS);
   Log_Area.Read_Only;

   Gnoga.Application.Singleton.Message_Loop;
exception
   when E : others =>
      Gnoga.Log (E);
end Udp_Sender;

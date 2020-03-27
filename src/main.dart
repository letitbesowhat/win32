import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import 'win32.dart';

final win32 = Win32();

int MainWindowProc(int hwnd, int uMsg, int wParam, int lParam) {
  switch (uMsg) {
    case WM_DESTROY:
      win32.PostQuitMessage(0);
      return 0;

    case WM_PAINT:
      var ps = PAINTSTRUCT.allocate();
      var hdc = win32.BeginPaint(hwnd, ps.addressOf);
      win32.FillRect(
          hdc, Pointer.fromAddress(ps.addressOf.address + 6), COLOR_WINDOW + 1);
      win32.EndPaint(hwnd, ps.addressOf);
      return 0;
  }
  return win32.DefWindowProc(hwnd, uMsg, wParam, lParam);
}

int main() {
  final hInstance = win32.GetModuleHandle(nullptr);

  // Register the window class.

  var CLASS_NAME = Utf16.toUtf16('Sample Window Class');
  var wc = WNDCLASS.allocate();
  wc.lpfnWndProc = Pointer.fromFunction<windowProcNative>(MainWindowProc, 0);
  wc.hInstance = hInstance;
  wc.lpszClassName = CLASS_NAME;
  win32.RegisterClass(wc.addressOf);

  // Create the window.

  var hWnd = win32.CreateWindowEx(
      0, // Optional window styles.
      CLASS_NAME, // Window class
      Utf16.toUtf16('Dart Native Win32 window'), // Window text
      WS_OVERLAPPEDWINDOW, // Window style

      // Size and position
      CW_USEDEFAULT,
      CW_USEDEFAULT,
      CW_USEDEFAULT,
      CW_USEDEFAULT,
      NULL, // Parent window
      NULL, // Menu
      hInstance, // Instance handle
      nullptr // Additional application data
      );

  if (hWnd == 0) {
    stderr.writeln('CreateWindowEx failed with error: ${win32.GetLastError()}');
    return -1;
  }

  win32.ShowWindow(hWnd, SW_SHOWNORMAL);

  // Run the message loop.

  var msg = MSG.allocate();
  while (win32.GetMessage(msg.addressOf, NULL, 0, 0) != 0) {
    win32.TranslateMessage(msg.addressOf);
    win32.DispatchMessage(msg.addressOf);
  }

  // TODO: Is this necessary? Won't Dart tear this down anyway?
  free(wc.addressOf);
  free(CLASS_NAME);

  return 0;
}
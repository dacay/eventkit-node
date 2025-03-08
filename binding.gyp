{
  "targets": [
    {
      "target_name": "eventkit",
      "sources": ["node-addon/eventkit_binding.mm"],
      "libraries": ["<(module_root_dir)/libEventKitBridge.a"],
      "include_dirs": [
        "<!@(node -p \"require('node-addon-api').include\")",
        ".",
        "node-addon"
      ],
      "frameworks": ["EventKit", "Foundation"],
      "dependencies": [
        "<!(node -p \"require('node-addon-api').gyp\")"
      ],
      "cflags!": ["-fno-exceptions"],
      "cflags_cc!": ["-fno-exceptions"],
      "xcode_settings": {
        "GCC_ENABLE_CPP_EXCEPTIONS": "YES",
        "CLANG_CXX_LIBRARY": "libc++",
        "OTHER_LDFLAGS": [
          "-framework EventKit",
          "-framework Foundation"
        ]
      },
      "defines": [
        "NAPI_DISABLE_CPP_EXCEPTIONS",
        "NAPI_VERSION=8"
      ]
    }
  ]
}
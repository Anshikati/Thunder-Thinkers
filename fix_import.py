import os

path = 'lib/screens/volunteer/volunteer_home_content.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add at top
if "import 'package:go_router/go_router.dart';" not in content[:500]:
    content = content.replace("import 'package:provider/provider.dart';", "import 'package:provider/provider.dart';\nimport 'package:go_router/go_router.dart';")

# Remove from build
content = content.replace("    import 'package:go_router/go_router.dart';\n", "")

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

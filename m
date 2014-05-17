Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f43.google.com ([209.85.219.43]:49271 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932261AbaEQKrS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 May 2014 06:47:18 -0400
Received: by mail-oa0-f43.google.com with SMTP id l6so4204823oag.16
        for <linux-nfs@vger.kernel.org>; Sat, 17 May 2014 03:47:18 -0700 (PDT)
Message-ID: <53773E28.5010206@gmail.com>
Date: Sat, 17 May 2014 18:47:04 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, kinglongmee@gmail.com
Subject: [PATCH] NFS4.0: Add IPv6 support
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.0/lib/rpc/rpc.py | 15 ++++++++-----
 nfs4.0/nfs4lib.py     | 61 +++++++++++++++++++++++++++++++++++++++++++++++++++
 nfs4.0/testserver.py  | 26 +++++-----------------
 3 files changed, 77 insertions(+), 25 deletions(-)

diff --git a/nfs4.0/lib/rpc/rpc.py b/nfs4.0/lib/rpc/rpc.py
index 60f70bd..8b39df4 100644
--- a/nfs4.0/lib/rpc/rpc.py
+++ b/nfs4.0/lib/rpc/rpc.py
@@ -188,6 +188,9 @@ class RPCClient(object):
         self.debug = 0
         t = threading.currentThread()
         self.lock = threading.Lock()
+        self.af = socket.AF_INET;
+        if host.find(':') != -1:
+            self.af = socket.AF_INET6;
         self.remotehost = host
         self.remoteport = port
         self.timeout = timeout
@@ -207,6 +210,7 @@ class RPCClient(object):
         self._init_security(self.sec_list) # Note this can make calls
         self.security = sec_list[0]
 
+
     def _init_security(self, list):
         # Each element of list must have functions:
         # initialize, secure_data, make_cred, make_verf
@@ -235,8 +239,7 @@ class RPCClient(object):
         if t in self._socket:
             out = self._socket[t]
         else:
-            out = self._socket[t] = socket.socket(socket.AF_INET,
-                                                  socket.SOCK_STREAM)
+            out = self._socket[t] = socket.socket(self.af, socket.SOCK_STREAM)
             if self.uselowport:
                 self.bindsocket(out)
             out.connect((self.remotehost, self.remoteport))
@@ -301,8 +304,7 @@ class RPCClient(object):
         t = threading.currentThread()
         self.lock.acquire()
         self._socket[t].close()
-        out = self._socket[t] = socket.socket(socket.AF_INET,
-                                              socket.SOCK_STREAM)
+        out = self._socket[t] = socket.socket(self.af, socket.SOCK_STREAM)
         # out.bind
         out.connect((self.remotehost, self.remoteport))
         out.settimeout(self.timeout)
@@ -454,7 +456,10 @@ class RPCClient(object):
 
 class Server(object):
     def __init__(self, host='', port=51423, name="SERVER"):
-        self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
+        try:
+            self.s = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
+        except:
+            self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
         self.s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
         self.s.bind((host, port))
         self.port = self.s.getsockname()[1]
diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index 5fc7bf3..994e0e1 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -39,6 +39,7 @@ import time
 import struct
 import socket
 import sys
+import re
 
 class NFSException(rpc.RPCError):
     pass
@@ -1013,4 +1014,64 @@ def bitmap2list(bitmap):
         bitmap >>= 1
     return out
 
+def path_components(path, use_dots=True):
+    """Convert a string '/a/b/c' into an array ['a', 'b', 'c']"""
+    out = []
+    for c in path.split('/'):
+        if c == '':
+            pass
+        elif use_dots and c == '.':
+            pass
+        elif use_dots and c == '..':
+            del out[-1]
+
+def parse_nfs_url(url):
+    """Parse [nfs://]host:port/path, format taken from rfc 2224
+       multipath addr:port pair are as such:
+
+      $ip1:$port1,$ip2:$port2..
+
+    Returns triple server, port, path.
+    """
+    p = re.compile(r"""
+    (?:nfs://)?               # Ignore an optionally prepended 'nfs://'
+    (?P<servers>[^/]+)
+    (?P<path>/.*)?            # set path=everything else, must start with /
+    $
+    """, re.VERBOSE)
+
+    m = p.match(url)
+    if m:
+        servers = m.group('servers')
+        server_list = []
+
+        for server in servers.split(','):
+            server = server.strip()
+
+            idx = server.rfind(':')
+            bracket_idx = server.rfind(']')
+
+            # the first : is before ipv6 addr ] -> no port specified
+            if bracket_idx > idx:
+                idx = -1
+
+            if idx >= 0:
+                host = server[:idx]
+                port = server[idx+1:]
+            else:
+                host = server
+                port = None
+
+            # remove brackets around IPv6 addrs, if they exist
+            if host.startswith('[') and host.endswith(']'):
+                host = host[1:-1]
+
+            port = (2049 if not port else int(port))
+            server_list.append((host, port))
 
+        path = m.group('path')
+        path = (path_components(path) if path else [])
+
+        return tuple(server_list), path
+    else:
+        raise ValueError("Error parsing NFS URL: %s" % url)
diff --git a/nfs4.0/testserver.py b/nfs4.0/testserver.py
index 606e2f0..41be74a 100755
--- a/nfs4.0/testserver.py
+++ b/nfs4.0/testserver.py
@@ -35,7 +35,6 @@ if  __name__ == "__main__":
     if os.path.isfile(os.path.join(sys.path[0], 'lib', 'testmod.py')):
         sys.path.insert(1, os.path.join(sys.path[0], 'lib'))
 
-import re
 import nfs4lib
 import testmod
 from optparse import OptionParser, OptionGroup, IndentedHelpFormatter
@@ -57,23 +56,6 @@ if not hasattr(os, "getgid"):
 else:
     GID = os.getgid()
 
-
-def parse_url(url):
-    """Parse [nfs://]host:port/path"""
-    p = re.compile(r"""
-    (?:nfs://)?      # Ignore an optionally prepended 'nfs://'
-    (?P<host>[^:]+)  # set host=everything up to next :
-    :?
-    (?P<port>[^/]*)  # set port=everything up to next /
-    (?P<path>/.*$|$) # set path=everything else
-    """, re.VERBOSE)
-
-    m = p.match(url)
-    if m:
-        return m.group('host'), m.group('port'), m.group('path')
-    else:
-        return None, None, None
-        
 def unixpath2comps(str, pathcomps=None):
     if pathcomps is None or str[0] == '/':
         pathcomps = []
@@ -284,9 +266,13 @@ def main():
     if not args:
         p.error("Need a server")
     url = args.pop(0)
-    opt.server, opt.port, opt.path = parse_url(url)
-    if not opt.server:
+    server_list, opt.path = nfs4lib.parse_nfs_url(url)
+
+    if not server_list:
         p.error("%s not a valid server name" % url)
+
+    opt.server, opt.port = server_list[0]
+
     if not opt.port:
         opt.port = 2049
     else:
-- 
1.9.0


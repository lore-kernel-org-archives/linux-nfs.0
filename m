Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:53708 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388421AbeGXIj0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:26 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 14/24] pynfs: python3 support plan: Relative Import -> Absolute Import
Date: Tue, 24 Jul 2018 15:33:32 +0800
Message-Id: <20180724073342.5738-14-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/lib/rpc/rpc.py                  | 23 ++++++++++++-----------
 nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py  |  2 +-
 nfs4.0/lib/rpc/rpcsec/sec_auth_none.py |  2 +-
 nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py  |  2 +-
 nfs4.0/nfs4lib.py                      | 20 +++++++++++---------
 xdr/xdrgen.py                          |  4 +++-
 6 files changed, 29 insertions(+), 24 deletions(-)

diff --git a/nfs4.0/lib/rpc/rpc.py b/nfs4.0/lib/rpc/rpc.py
index be14658..86075b2 100644
--- a/nfs4.0/lib/rpc/rpc.py
+++ b/nfs4.0/lib/rpc/rpc.py
@@ -7,6 +7,7 @@
 #                    Information Technology Integration
 #
 
+from __future__ import absolute_import
 import struct
 import xdrlib
 import socket
@@ -14,17 +15,17 @@ import select
 import threading
 import errno
 
-from rpc_const import *
-from rpc_type import *
-import rpc_pack
+from rpc.rpc_const import *
+from rpc.rpc_type import *
+import rpc.rpc_pack as rpc_pack
 
 # Import security flavors and store valid ones
-from rpcsec.sec_auth_none import SecAuthNone
-from rpcsec.sec_auth_sys import SecAuthSys
+from .rpcsec.sec_auth_none import SecAuthNone
+from .rpcsec.sec_auth_sys import SecAuthSys
 supported = {'none' : SecAuthNone,
              'sys'  : SecAuthSys }
 try:
-    from rpcsec.sec_auth_gss import SecAuthGss
+    from .rpcsec.sec_auth_gss import SecAuthGss
     supported['gss'] = SecAuthGss
 except ImportError:
     pass
@@ -427,11 +428,11 @@ class RPCClient(object):
         cred = self.security.make_cred()
         p.pack_uint(xid)
         p.pack_enum(CALL)
-	p.pack_uint(RPCVERSION)
-	p.pack_uint(prog)
-	p.pack_uint(vers)
-	p.pack_uint(proc)
-	p.pack_opaque_auth(cred)
+        p.pack_uint(RPCVERSION)
+        p.pack_uint(prog)
+        p.pack_uint(vers)
+        p.pack_uint(proc)
+        p.pack_opaque_auth(cred)
         verf = self.security.make_verf(p.get_buffer())
         p.pack_opaque_auth(verf)
         return p.get_buffer(), cred
diff --git a/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py b/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py
index ee6ad53..1b5eb93 100644
--- a/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py
+++ b/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py
@@ -1,4 +1,4 @@
-from base import SecFlavor, SecError
+from .base import SecFlavor, SecError
 from rpc.rpc_const import RPCSEC_GSS
 from rpc.rpc_type import opaque_auth
 from gss_const import *
diff --git a/nfs4.0/lib/rpc/rpcsec/sec_auth_none.py b/nfs4.0/lib/rpc/rpcsec/sec_auth_none.py
index 7058203..ec8896a 100644
--- a/nfs4.0/lib/rpc/rpcsec/sec_auth_none.py
+++ b/nfs4.0/lib/rpc/rpcsec/sec_auth_none.py
@@ -1,4 +1,4 @@
-from base import SecFlavor
+from .base import SecFlavor
 
 class SecAuthNone(SecFlavor):
     pass
diff --git a/nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py b/nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py
index 27fc52e..778d379 100644
--- a/nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py
+++ b/nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py
@@ -1,4 +1,4 @@
-from base import SecFlavor, SecError
+from .base import SecFlavor, SecError
 from rpc.rpc_const import AUTH_SYS
 from rpc.rpc_type import opaque_auth
 from xdrlib import Packer, Error
diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index 6f6d2f9..79e386e 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -24,16 +24,8 @@
 # along with this program; if not, write to the Free Software
 # Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 
+from __future__ import absolute_import
 
-
-import rpc
-import threading
-from xdrlib import Error as XDRError
-import xdrdef.nfs4_const as nfs4_const
-from xdrdef.nfs4_const import *
-import xdrdef.nfs4_type as nfs4_type
-from xdrdef.nfs4_type import *
-import xdrdef.nfs4_pack as nfs4_pack
 import time
 import struct
 import socket
@@ -41,6 +33,16 @@ import sys
 import re
 import inspect
 from os.path import basename
+import threading
+
+import rpc.rpc as rpc
+import rpc.rpc_const as rpc_const
+import xdrdef.nfs4_const as nfs4_const
+from  xdrdef.nfs4_const import *
+import xdrdef.nfs4_type as nfs4_type
+from xdrdef.nfs4_type import *
+from xdrlib import Error as XDRError
+import xdrdef.nfs4_pack as nfs4_pack
 
 import nfs_ops
 op4 = nfs_ops.NFS4ops()
diff --git a/xdr/xdrgen.py b/xdr/xdrgen.py
index 6303184..abfc8d7 100755
--- a/xdr/xdrgen.py
+++ b/xdr/xdrgen.py
@@ -1354,6 +1354,8 @@ allow_attr_passthrough = True # Option which allows substructure attrs to
                               # be referenced directly, in cases where there
                               # is a unique substructure to search.
 pack_header = """\
+import sys,os
+sys.path.append(os.path.dirname(__file__))
 import %s as const
 import %s as types
 import xdrlib
@@ -1438,7 +1440,7 @@ def run(infile, filters=True, pass_attrs=True, debug=False):
     const_fd.write(comment_string)
     type_fd = open(types_file + ".py", "w")
     type_fd.write(comment_string)
-    type_fd.write("import %s as const\n" % constants_file)
+    type_fd.write("import sys,os\nsys.path.append(os.path.dirname(__file__))\nimport %s as const\n" % constants_file)
     pack_fd = open(packer_file + ".py", "w")
     pack_fd.write(comment_string)
     pack_fd.write(pack_header % (constants_file, types_file))
-- 
2.17.1


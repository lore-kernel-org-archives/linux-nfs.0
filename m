Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38068 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbaFEN4B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:56:01 -0400
Received: by mail-ig0-f180.google.com with SMTP id c1so2326092igq.7
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 06:56:00 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs v2 13/16] 4.1 server: add support for NFSv3 data servers
Date: Thu,  5 Jun 2014 09:55:41 -0400
Message-Id: <1401976544-36374-14-git-send-email-dros@primarydata.com>
In-Reply-To: <1401976544-36374-1-git-send-email-dros@primarydata.com>
References: <1401976544-36374-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the NFSv3 client and a new DataServer class that handles DS ops
using the v3 client.

DataServer3 is not used yet, as it requires flexfile layouts in order
to pass a v3 DS to clients.

Tested with linux client mounting pnfs MDS via v4.1 (disabling pnfs)
and a linux server acting as the v3 DS.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/dataserver.py | 100 ++++++++++++++++++++++++++++
 nfs4.1/nfs3client.py | 180 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 280 insertions(+)
 create mode 100644 nfs4.1/nfs3client.py

diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index 5c604dc..f32f3d7 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -3,9 +3,12 @@ import nfs4lib
 import xdrdef.nfs4_type as type4
 from xdrdef.nfs4_pack import NFS4Packer
 import xdrdef.nfs4_const as const4
+import xdrdef.nfs3_type as type3
+import xdrdef.nfs3_const as const3
 import time
 import logging
 import nfs4client
+import nfs3client
 import hashlib
 import sys
 import nfs_ops
@@ -14,6 +17,7 @@ import socket
 log = logging.getLogger("Dataserver Manager")
 
 op4 = nfs_ops.NFS4ops()
+op3 = nfs_ops.NFS3ops()
 
 class DataServer(object):
     def __init__(self, server, port, path, flavor=rpc.AUTH_SYS, active=True, mdsds=True, multipath_servers=None, summary=None):
@@ -207,6 +211,102 @@ class DataServer41(DataServer):
         attrdict = res.resarray[-1].obj_attributes
         return attrdict.get(const4.FATTR4_SIZE, 0)
 
+class DataServer3(DataServer):
+    def _execute(self, procnum, procarg, exceptions=(), delay=5, maxretries=3):
+        """ execute the NFS call
+        If an error code is specified in the exceptions it means that the
+        caller wants to handle the error himself
+        """
+        retry_errors = []
+        while True:
+            res = self.c1.proc(procnum, procarg)
+            if res.status == const3.NFS3_OK or res.status in exceptions:
+                return res
+            elif res.status in retry_errors:
+                if maxretries > 0:
+                    maxretries -= 1
+                    time.sleep(delay)
+                else:
+                    log.error("Too many retries with DS %s" % self.server)
+                    raise Exception("Dataserver communication retry error")
+            else:
+                log.error("Unhandled status %s from DS %s" %
+                          (const3.nfsstat3[res.status], self.server))
+                raise Exception("Dataserver communication error")
+
+    def connect(self):
+        # only support root with AUTH_SYS for now
+        s1 = rpc.security.instance(rpc.AUTH_SYS)
+        self.cred1 = s1.init_cred(uid=0, gid=0)
+        self.c1 = nfs3client.NFS3Client(self.server, self.port,
+                                        summary=self.summary)
+        self.c1.set_cred(self.cred1)
+        self.rootfh = type3.nfs_fh3(self.c1.mntclnt.get_rootfh(self.path))
+        self.c1.null()
+
+    def make_root(self):
+        """ don't actually make a root path - we must use it as the export """
+        need = const3.ACCESS3_READ | const3.ACCESS3_LOOKUP | \
+               const3.ACCESS3_MODIFY | const3.ACCESS3_EXTEND
+        arg = op3.access(self.rootfh, need)
+        res = self._execute(const3.NFSPROC3_ACCESS, arg)
+        if res.resok.access != need:
+            raise RuntimeError
+        # XXX clean DS directory
+
+    def open_file(self, mds_fh):
+        name = self.fh_to_name(mds_fh)
+        where = type3.diropargs3(self.rootfh, name)
+        attr = type3.sattr3(mode=type3.set_mode3(True, 0777),
+                            uid=type3.set_uid3(True, 0),
+                            gid=type3.set_gid3(True, 0),
+                            size=type3.set_size3(False),
+                            atime=type3.set_atime(False),
+                            mtime=type3.set_mtime(False))
+        how = type3.createhow3(const3.GUARDED, attr)
+        arg = op3.create(where, how)
+        res = self._execute(const3.NFSPROC3_CREATE, arg,
+                            exceptions=(const3.NFS3ERR_EXIST,))
+
+        if res.status == const3.NFS3_OK:
+            self.filehandles[mds_fh] = (res.resok.obj.handle, None)
+
+        else:
+            arg = op3.lookup(type3.diropargs3(self.rootfh, name))
+            res = self._execute(const3.NFSPROC3_LOOKUP, arg)
+
+            self.filehandles[mds_fh] = (res.resok.object, None)
+
+    def close_file(self, mds_fh):
+        del self.filehandles[mds_fh]
+
+    def read(self, fh, pos, count):
+        arg = op3.read(fh, pos, count)
+        res = self._execute(const3.NFSPROC3_READ, arg)
+        # XXX check res.status?
+        return res.resok.data
+
+    def write(self, fh, pos, data):
+        arg = op3.write(fh, pos, len(data), const3.FILE_SYNC, data)
+        # There are all sorts of error handling issues here
+        res = self._execute(const3.NFSPROC3_WRITE, arg)
+
+    def truncate(self, fh, size):
+        attr = type3.sattr3(mode=type3.set_mode3(False),
+                            uid=type3.set_uid3(False),
+                            gid=type3.set_gid3(False),
+                            size=type3.set_size3(True, size),
+                            atime=type3.set_atime(False),
+                            mtime=type3.set_mtime(False))
+        arg = op3.setattr(fh, attr, type3.sattrguard3(check=False))
+        res = self._execute(const3.NFSPROC3_SETATTR, arg)
+
+    def get_size(self, fh):
+        arg = op3.getattr(fh)
+        res = self._execute(const3.NFSPROC3_GETATTR, arg)
+        # XXX check res.status?
+        return res.resok.obj_attributes.size
+
 
 class DSDevice(object):
     def __init__(self, mdsds):
diff --git a/nfs4.1/nfs3client.py b/nfs4.1/nfs3client.py
new file mode 100644
index 0000000..79a6f0e
--- /dev/null
+++ b/nfs4.1/nfs3client.py
@@ -0,0 +1,180 @@
+import use_local # HACK so don't have to rebuild constantly
+import rpc
+import nfs4lib
+#from nfs4lib import NFS4Error, NFS4Replay, inc_u32
+from xdrdef.sctrl_pack import SCTRLPacker, SCTRLUnpacker
+from xdrdef.nfs3_type import *
+from xdrdef.nfs3_const import *
+from xdrdef.nfs3_pack import NFS3Packer, NFS3Unpacker
+from xdrdef.mnt3_type import *
+from xdrdef.mnt3_const import *
+from xdrdef.mnt3_pack import MNT3Packer, MNT3Unpacker
+from xdrdef.portmap_type import *
+from xdrdef.portmap_const import *
+from xdrdef.portmap_pack import PORTMAPPacker, PORTMAPUnpacker
+import nfs_ops
+import time, struct
+import threading
+import hmac
+import os.path
+
+import traceback
+import logging
+logging.basicConfig(level=logging.INFO,
+                    format="%(levelname)-7s:%(name)s:%(message)s")
+log_cb = logging.getLogger("nfs.client.cb")
+
+op3 = nfs_ops.NFS3ops()
+
+class PORTMAPClient(rpc.Client):
+    def __init__(self, host='localhost', port=PMAP_PORT):
+        rpc.Client.__init__(self, PMAP_PROG, PMAP_VERS)
+        self.server_address = (host, port)
+        self.c1 = self.connect(self.server_address)
+
+    def proc_async(self, procnum, procarg, credinfo=None, pipe=None,
+                   checks=True, packer=PORTMAPPacker):
+        if credinfo is None:
+            credinfo = self.default_cred
+        if pipe is None:
+            pipe = self.c1
+        p = packer(check_enum=checks, check_array=checks)
+        arg_packer = getattr(p, 'pack_%s' % procarg.__class__.__name__)
+        arg_packer(procarg)
+        return self.send_call(pipe, procnum, p.get_buffer(), credinfo)
+
+    def proc(self, procnum, procarg, restypename, **kwargs):
+        xid = self.proc_async(procnum, procarg, **kwargs)
+        pipe = kwargs.get("pipe", None)
+        res = self.listen(xid, restypename, pipe=pipe)
+        return res
+
+    def listen(self, xid, restypename, pipe=None, timeout=10.0):
+        if pipe is None:
+            pipe = self.c1
+        header, data = pipe.listen(xid, timeout)
+        if data:
+            p = PORTMAPUnpacker(data)
+            res_unpacker = getattr(p, 'unpack_%s' % restypename)
+            data = res_unpacker()
+        return data
+
+    def get_port(self, prog, vers):
+        arg = mapping(prog, vers, IPPROTO_TCP, 0)
+
+        res = self.proc(PMAPPROC_GETPORT, arg, 'uint')
+        return res
+
+class Mnt3Client(rpc.Client):
+    def __init__(self, host='localhost', port=None):
+        rpc.Client.__init__(self, MOUNT_PROGRAM, MOUNT_V3)
+        self.server_address = (host, port)
+        self.c1 = self.connect(self.server_address)
+
+    def proc_async(self, procnum, procarg, credinfo=None, pipe=None,
+                   checks=True, packer=MNT3Packer):
+        if credinfo is None:
+            credinfo = self.default_cred
+        if pipe is None:
+            pipe = self.c1
+        p = packer(check_enum=checks, check_array=checks)
+        arg_packer = getattr(p, 'pack_%s' % procarg.__class__.__name__)
+        arg_packer(procarg)
+        return self.send_call(pipe, procnum, p.get_buffer(), credinfo)
+
+    def proc(self, procnum, procarg, restypename, **kwargs):
+        xid = self.proc_async(procnum, procarg, **kwargs)
+        pipe = kwargs.get("pipe", None)
+        res = self.listen(xid, restypename, pipe=pipe)
+        return res
+
+    def listen(self, xid, restypename, pipe=None, timeout=10.0):
+        if pipe is None:
+            pipe = self.c1
+        header, data = pipe.listen(xid, timeout)
+        if data:
+            p = MNT3Unpacker(data)
+            res_unpacker = getattr(p, 'unpack_%s' % restypename)
+            data = res_unpacker()
+        return data
+
+    def get_rootfh(self, export):
+
+        class dirpath(str):
+            pass
+
+        arg = dirpath('/' + os.path.join(*export))
+        res = self.proc(MOUNTPROC3_MNT, arg, 'mountres3')
+        return res.mountinfo.fhandle
+
+class NFS3Client(rpc.Client):
+    def __init__(self, host='localhost', port=None, ctrl_proc=16, summary=None):
+        rpc.Client.__init__(self, 100003, 3)
+        #self.prog = 0x40000000
+        #self.versions = [1] # List of supported versions of prog
+
+        #self.minorversion = minorversion
+        #self.minor_versions = [minorversion]
+        #self.tag = "default tag"
+        #self.impl_id = nfs_impl_id4("citi.umich.edu", "pynfs X.X",
+        #                            nfs4lib.get_nfstime())
+
+        self.portmap = PORTMAPClient(host=host)
+        self.mntport = self.portmap.get_port(MOUNT_PROGRAM, MOUNT_V3)
+        if not port:
+            self.port = self.portmap.get_port(100003, 3)
+        else:
+            self.port = port
+
+        self.verifier = struct.pack('>d', time.time())
+        self.server_address = (host, self.port)
+        self.c1 = self.connect(self.server_address)
+        #self.sessions = {} # XXX Really, this should be per server
+        self.ctrl_proc = ctrl_proc
+        self.summary = summary
+        self.mntclnt = Mnt3Client(host=host, port=self.mntport)
+
+    def set_cred(self, credinfo):
+        self.default_cred = credinfo
+
+    def null_async(self, data=""):
+        return self.send_call(self.c1, 0, data)
+
+    def null(self, *args, **kwargs):
+        xid = self.null_async(*args, **kwargs)
+        return self.listen(xid)
+
+    def proc_async(self, procnum, procarg, credinfo=None, pipe=None,
+                   checks=True, packer=NFS3Packer):
+        if credinfo is None:
+            credinfo = self.default_cred
+        if pipe is None:
+            pipe = self.c1
+        p = packer(check_enum=checks, check_array=checks)
+        arg_packer = getattr(p, 'pack_%s' % procarg.__class__.__name__)
+        arg_packer(procarg)
+        return self.send_call(pipe, procnum, p.get_buffer(), credinfo)
+
+    def proc(self, procnum, procarg, **kwargs):
+        xid = self.proc_async(procnum, procarg, **kwargs)
+        pipe = kwargs.get("pipe", None)
+        res = self.listen(xid, procarg=procarg, pipe=pipe)
+        if self.summary:
+            self.summary.show_op('call v3 %s:%s' % self.server_address,
+                [ procarg.__class__.__name__.lower()[:-1 * len('3args')] ],
+                nfsstat3[res.status])
+        return res
+
+    def listen(self, xid, procarg=None, pipe=None, timeout=10.0):
+        if pipe is None:
+            pipe = self.c1
+        header, data = pipe.listen(xid, timeout)
+        if data:
+            p = NFS3Unpacker(data)
+            argname = procarg.__class__.__name__
+            # FOO3args -> FOO3res
+            resname = argname[:-4] + 'res'
+            res_unpacker = getattr(p, 'unpack_%s' % resname)
+            data = res_unpacker()
+        return data
+
-- 
1.8.5.2 (Apple Git-48)


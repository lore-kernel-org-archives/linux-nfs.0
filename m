Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:62978 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbaFENz4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:55:56 -0400
Received: by mail-ie0-f179.google.com with SMTP id rd18so905613iec.38
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 06:55:55 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs v2 07/16] 4.1 server: add -s option to print summary of ops
Date: Thu,  5 Jun 2014 09:55:35 -0400
Message-Id: <1401976544-36374-8-git-send-email-dros@primarydata.com>
In-Reply-To: <1401976544-36374-1-git-send-email-dros@primarydata.com>
References: <1401976544-36374-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As a middle ground between verbose (-v) mode and silent mode, add
"-s" (aka "--show_summary") to print one line per operation.

The summary mode will print a "role" header whenever the role changes.

Example output - mds starts, talks to v3 ds (.200), client (.11) mounts,
touches an existing file:

call v3 172.16.200.200:2049
  access
Mounting (2, 6) on '/files'

handle v4.1 ::ffff:172.16.200.11:758
  exchange_id
  create_session
  sequence, reclaim_complete
  sequence, putrootfh, secinfo_no_name
  sequence, putrootfh, getfh, getattr
  sequence, putfh, getattr
  (repeated 6 times)
  sequence, putfh, access, getattr
  sequence, putfh, lookup, getfh, getattr
  (repeated 1 times)
  sequence, putfh, secinfo -> NFS4ERR_NOTSUPP
  sequence, putfh, getattr
  (repeated 4 times)
  sequence, putfh, access, getattr

call v3 172.16.200.200:2049
  create -> NFS3ERR_EXIST
  lookup
  getattr
  (repeated 1 times)

handle v4.1 ::ffff:172.16.200.11:758
  sequence, putfh, open, getfh, access, getattr

call v3 172.16.200.200:2049
  getattr
  (repeated 1 times)

handle v4.1 ::ffff:172.16.200.11:758
  sequence, putfh, setattr, getattr
  sequence, putfh, close, getattr

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/dataserver.py     | 16 ++++++++++------
 nfs4.1/nfs4client.py     |  7 ++++++-
 nfs4.1/nfs4server.py     | 47 ++++++++++++++++++++++++++++++++++++++++++++++-
 nfs4.1/server_exports.py |  7 ++++---
 4 files changed, 66 insertions(+), 11 deletions(-)

diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index c400d22..dd81b20 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -13,8 +13,8 @@ import socket
 
 log = logging.getLogger("Dataserver Manager")
 
-class DataServer(object):
-    def __init__(self, server, port, path, flavor=rpc.AUTH_SYS, active=True, mdsds=True, multipath_servers=None):
+class DataServer41(object):
+    def __init__(self, server, port, path, flavor=rpc.AUTH_SYS, active=True, mdsds=True, multipath_servers=None, summary=None):
         self.mdsds = mdsds
         self.server = server
         self.port = int(port)
@@ -32,6 +32,8 @@ class DataServer(object):
         else:
             self.multipath_servers = []
 
+        self.summary = summary
+
         if active:
             self.up()
 
@@ -47,7 +49,8 @@ class DataServer(object):
         # only support root with AUTH_SYS for now
         s1 = rpc.security.instance(rpc.AUTH_SYS)
         self.cred1 = s1.init_cred(uid=0, gid=0)
-        self.c1 = nfs4client.NFS4Client(self.server, self.port)
+        self.c1 = nfs4client.NFS4Client(self.server, self.port,
+                                        summary=self.summary)
         self.c1.set_cred(self.cred1)
         self.c1.null()
         c = self.c1.new_client("DS.init_%s" % self.server)
@@ -173,7 +176,7 @@ class DSDevice(object):
         self.address_body = None # set by load()
         self.mdsds = mdsds # if you are both the DS and the MDS we are the only server
 
-    def load(self, filename):
+    def load(self, filename, server_obj):
         """ Read dataservers from configuration file:
         where each line has format e.g. server[:[port][/path]]
         """
@@ -195,8 +198,9 @@ class DSDevice(object):
                 try:
                     log.info("Adding dataserver ip:%s port:%s path:%s" %
                              (server, port, '/'.join(path)))
-                    ds = DataServer(server, port, path, mdsds=self.mdsds,
-                                    multipath_servers=server_list)
+                    ds = DataServer41(server, port, path, mdsds=self.mdsds,
+                                    multipath_servers=server_list,
+                                    summary=server_obj.summary)
                     self.list.append(ds)
                 except socket.error:
                     log.critical("cannot access %s:%i/%s" %
diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 0ba84bd..4ae884a 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -21,7 +21,7 @@ logging.basicConfig(level=logging.INFO,
 log_cb = logging.getLogger("nfs.client.cb")
 
 class NFS4Client(rpc.Client, rpc.Server):
-    def __init__(self, host='localhost', port=2049, minorversion=1, ctrl_proc=16):
+    def __init__(self, host='localhost', port=2049, minorversion=1, ctrl_proc=16, summary=None):
         rpc.Client.__init__(self, 100003, 4)
         self.prog = 0x40000000
         self.versions = [1] # List of supported versions of prog
@@ -36,6 +36,7 @@ class NFS4Client(rpc.Client, rpc.Server):
         self.c1 = self.connect(self.server_address)
         self.sessions = {} # XXX Really, this should be per server
         self.ctrl_proc = ctrl_proc
+        self.summary = summary
 
     def set_cred(self, credinfo):
         self.default_cred = credinfo
@@ -83,6 +84,10 @@ class NFS4Client(rpc.Client, rpc.Server):
         pipe = kwargs.get("pipe", None)
         res = self.listen(xid, pipe=pipe)
         log_cb.info("compound result = %r" % (res,))
+        if self.summary:
+            self.summary.show_op('call v4.1 %s:%s' % self.server_address,
+                [ nfs_opnum4[a.argop].lower()[3:] for a in args[0] ],
+                nfsstat4[res.status])
         return res
     
     def listen(self, xid, pipe=None, timeout=10.0):
diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
index a495d3c..3d2d4cf 100755
--- a/nfs4.1/nfs4server.py
+++ b/nfs4.1/nfs4server.py
@@ -502,6 +502,41 @@ class Slot(object):
 
     # STUB - for client, need to track slot usage
 
+class SummaryOutput:
+    def __init__(self, enabled=True):
+        self._enabled = enabled
+        self._last = None
+        self._last_role = None
+        self._repeat_count = 0
+
+    def show_op(self, role, opnames, status):
+        if not self._enabled:
+            return
+
+        summary_line = "  %s" % ', '.join(opnames)
+
+        if status != "NFS4_OK" and status != "NFS3_OK":
+            summary_line += " -> %s" % (status,)
+
+        print_summary_line = True
+        if summary_line != self._last or role != self._last_role:
+            if self._last and self._repeat_count:
+                print "  (repeated %u times)" % self._repeat_count
+            self._last = summary_line
+            self._repeat_count = 0
+        else:
+            print_summary_line = False
+            self._repeat_count += 1
+
+        if self._last_role != role:
+            print
+            print role
+            self._last_role = role
+
+        if print_summary_line:
+            print summary_line
+
+
 ##################################################
 # The primary class - it is excessively long     #
 ##################################################
@@ -527,6 +562,8 @@ class NFS4Server(rpc.Server):
             log_41.setLevel(9)
             log_cfg.setLevel(20)
 
+        self.summary = SummaryOutput(kwargs.pop('show_summary', False))
+
         rpc.Server.__init__(self, prog=NFS4_PROGRAM, versions=[4], port=port,
                             **kwargs)
         self.root = RootFS().root # Root of exported filesystem tree
@@ -776,6 +813,7 @@ class NFS4Server(rpc.Server):
             return env
         # Handle the individual operations
         status = NFS4_OK
+        opnames = []
         for arg in args.argarray:
             opname = nfs_opnum4.get(arg.argop, 'op_illegal')
             log_41.info("*** %s (%d) ***" % (opname, arg.argop))
@@ -805,10 +843,14 @@ class NFS4Server(rpc.Server):
                     result = encode_status_by_name(opname.lower()[3:],
                                                    NFS4ERR_SERVERFAULT)
             env.results.append(result)
+            opnames.append(opname.lower()[3:])
             status = result.status
             if status != NFS4_OK:
                 break
         log_41.info("Replying.  Status %s (%d)" % (nfsstat4[status], status))
+        client_addr = '%s:%s' % cred.connection._s.getpeername()[:2]
+        self.summary.show_op('handle v4.1 %s' % client_addr,
+                             opnames, nfsstat4[status])
         return env
 
     def delete_session(self, session, sessionid):
@@ -2059,6 +2101,8 @@ def scan_options():
                  help="Reset and clear any disk-based filesystems")
     p.add_option("-v", "--verbose", action="store_true", default=False,
                  help="Print debug info to screen and enter interpreter on ^C")
+    p.add_option("-s", "--show_summary", action="store_true", default=False,
+                 help="Print short summary of operations")
     p.add_option("--use_block", action="store_true", default=False,
                  help="Mount a block-pnfs fs")
     p.add_option("--use_files", action="store_true", default=False,
@@ -2092,7 +2136,8 @@ if __name__ == "__main__":
     S = NFS4Server(port=opts.port,
                    is_mds=opts.use_block or opts.use_files,
                    is_ds = opts.is_ds,
-                   verbose = opts.verbose)
+                   verbose = opts.verbose,
+                   show_summary = opts.show_summary)
     read_exports(S, opts)
     if True:
         S.start()
diff --git a/nfs4.1/server_exports.py b/nfs4.1/server_exports.py
index d96b27b..ef857ee 100644
--- a/nfs4.1/server_exports.py
+++ b/nfs4.1/server_exports.py
@@ -15,7 +15,7 @@ def mount_stuff(server, opts):
         E = BlockLayoutFS(5, backing_device=dev)
         server.mount(E, path="/block")
     if opts.use_files:
-        dservers = _load_dataservers(opts.dataservers, server.is_ds and server.is_mds)
+        dservers = _load_dataservers(opts.dataservers, server)
         if dservers is None:
             return
         F = FileLayoutFS(6, dservers)
@@ -33,7 +33,8 @@ def _create_simple_block_dev():
     c1 = Concat([s3, s1])
     return BlockVolume(c1)
 
-def _load_dataservers(file, connect_to_ds=False):
+def _load_dataservers(filename, server):
+    connect_to_ds = server.is_ds and server.is_mds
     dss = DSDevice(connect_to_ds)
-    dss.load(file)
+    dss.load(filename, server)
     return dss;
-- 
1.8.5.2 (Apple Git-48)


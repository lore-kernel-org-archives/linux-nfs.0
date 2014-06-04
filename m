Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:51171 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbaFDVCX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 17:02:23 -0400
Received: by mail-ig0-f176.google.com with SMTP id a13so2456239igq.3
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 14:02:23 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs 07/17] 4.1 server: add -v flag & silence random output
Date: Wed,  4 Jun 2014 17:01:55 -0400
Message-Id: <1401915726-29092-8-git-send-email-dros@primarydata.com>
In-Reply-To: <1401915726-29092-1-git-send-email-dros@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By default the nfs4server spews so much information to stdout/stderr
that it's almost useless.  Add the -v flag (aka --verbose) to enable
the old output.

Also remove some random prints and change some to log.info().

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/dataserver.py |  3 +--
 nfs4.1/fs.py         |  4 ----
 nfs4.1/nfs4client.py | 11 ++--------
 nfs4.1/nfs4server.py | 61 +++++++++++++++++++++++-----------------------------
 nfs4.1/nfs4state.py  |  1 -
 5 files changed, 30 insertions(+), 50 deletions(-)

diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index 7f5f72c..d697631 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -181,7 +181,7 @@ class DSDevice(object):
                 line = line.strip()
                 if not line or line.startswith('#'):
                     continue
-                print "Analyzing: %r" % line
+                log.info("Analyzing: %r" % line)
                 try:
                     server_list, path = nfs4lib.parse_nfs_url(line)
                 except:
@@ -191,7 +191,6 @@ class DSDevice(object):
                 # for now, just use the last path for local connections
                 server, port = server_list[-1]
                 server_list = server_list[:-1]
-                print server, port, path
                 try:
                     log.info("Adding dataserver ip:%s port:%s path:%s" %
                              (server, port, '/'.join(path)))
diff --git a/nfs4.1/fs.py b/nfs4.1/fs.py
index 3d63ce5..6ef283b 100644
--- a/nfs4.1/fs.py
+++ b/nfs4.1/fs.py
@@ -13,7 +13,6 @@ from xdrdef.nfs4_pack import NFS4Packer
 log_o = logging.getLogger("fs.obj")
 log_fs = logging.getLogger("fs")
 logging.addLevelName(5, "FUNCT")
-log_fs.setLevel(20)
 
 class MetaData(object):
     """Contains everything that needs to be stored
@@ -743,7 +742,6 @@ class ConfigObj(FSObject):
             line = line.strip()
             if line and not line.startswith("#"):
                 lines.append(line)
-        print lines
         if len(lines) != 1:
             self._reset()
             return
@@ -1154,7 +1152,6 @@ class LayoutFSObj(FSObject):
                                             disk_offset,
                                             e.state))
         block_layout = pnfs_block_layout4(elist)
-        print block_layout
         p = block.Packer()
         p.pack_pnfs_block_layout4(block_layout)
 ##         if self.id <= 4:
@@ -1194,7 +1191,6 @@ class LayoutFSObj(FSObject):
                 log_o.exception("Problem decoding opaque")
                 raise NFS4Error(NFS4ERR_BADLAYOUT, tag="Error decoding opaque")
             upd_list = update.blu_commit_list
-            print upd_list
         # Error check
         for e in upd_list:
             if e.bex_state != block.PNFS_BLOCK_READWRITE_DATA:
diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 0904577..e504362 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -19,9 +19,7 @@ import logging
 logging.basicConfig(level=logging.INFO,
                     format="%(levelname)-7s:%(name)s:%(message)s")
 log_cb = logging.getLogger("nfs.client.cb")
-log_cb.setLevel(logging.DEBUG)
 
-SHOW_TRAFFIC = True # Debugging aid, prints out client traffic
 class NFS4Client(rpc.Client, rpc.Server):
     def __init__(self, host='localhost', port=2049, minorversion=1, ctrl_proc=16):
         rpc.Client.__init__(self, 100003, 4)
@@ -76,9 +74,7 @@ class NFS4Client(rpc.Client, rpc.Server):
             pipe = self.c1
         p = packer(check_enum=checks, check_array=checks)
         c4 = COMPOUND4args(tag, version, ops)
-        if SHOW_TRAFFIC:
-            print
-            print c4
+        log_cb.info("compound args = %r" % (c4,))
         p.pack_COMPOUND4args(c4)
         return self.send_call(pipe, 1, p.get_buffer(), credinfo)
 
@@ -86,19 +82,16 @@ class NFS4Client(rpc.Client, rpc.Server):
         xid = self.compound_async(*args, **kwargs)
         pipe = kwargs.get("pipe", None)
         res = self.listen(xid, pipe=pipe)
-        if SHOW_TRAFFIC:
-            print res
+        log_cb.info("compound result = %r" % (res,))
         return res
     
     def listen(self, xid, pipe=None, timeout=10.0):
         if pipe is None:
             pipe = self.c1
         header, data = pipe.listen(xid, timeout)
-        #print "HEADER", header
         if data:
             p = nfs4lib.FancyNFS4Unpacker(data)
             data = p.unpack_COMPOUND4res()
-        #print "DATA", repr(data)
         return data
 
     def handle_0(self, data, cred):
diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
index 75276f9..67adbf1 100755
--- a/nfs4.1/nfs4server.py
+++ b/nfs4.1/nfs4server.py
@@ -21,14 +21,11 @@ from nfs4commoncode import CompoundState, encode_status, encode_status_by_name
 from fs import RootFS, ConfigFS
 from config import ServerConfig, ServerPerClientConfig, OpsConfigServer, Actions
 
-logging.basicConfig(level=logging.INFO,
+logging.basicConfig(level=logging.WARN,
                     format="%(levelname)-7s:%(name)s:%(message)s")
 log_41 = logging.getLogger("nfs.server")
-log_41.setLevel(logging.DEBUG)
-log_41.setLevel(9)
 
 log_cfg = logging.getLogger("nfs.server.opconfig")
-log_cfg.setLevel(20)
 
 ##################################################
 # Set various global constants and magic numbers #
@@ -116,9 +113,6 @@ class Recording(object):
     def add(self, call, reply):
         """Add call and reply strings to records"""
         if self.on:
-            print "Adding"
-            print repr(call)
-            print repr(reply)
             self.queue.appendleft((call, reply))
 
     def set_stamp(self, stamp):
@@ -269,13 +263,13 @@ class VerboseDict(dict):
         self.config = config
 
     def __setitem__(self, key, value):
-        if 0 or self.config.debug_state:
-            print "+++ Adding client.state[%r]" % key
+        if self.config.debug_state:
+            log_41.info("+++ Adding client.state[%r]" % key)
         dict.__setitem__(self, key, value)
 
     def __delitem__(self, key):
-        if 0 or self.config.debug_state:
-            print "+++ Removing client.state[%r]" % key
+        if self.config.debug_state:
+            log_41.info("+++ Removing client.state[%r]" % key)
         dict.__delitem__(self, key)
         
 class ClientRecord(object):
@@ -526,6 +520,13 @@ class NFS4Server(rpc.Server):
         port = kwargs.pop("port", NFS4_PORT)
         self.is_mds = kwargs.pop("is_mds", False)
         self.is_ds = kwargs.pop("is_ds", False)
+
+        self.verbose = kwargs.pop('verbose', False)
+        if self.verbose:
+            log_41.setLevel(logging.DEBUG) # XXX redundant?
+            log_41.setLevel(9)
+            log_cfg.setLevel(20)
+
         rpc.Server.__init__(self, prog=NFS4_PROGRAM, versions=[4], port=port,
                             **kwargs)
         self.root = RootFS().root # Root of exported filesystem tree
@@ -552,7 +553,7 @@ class NFS4Server(rpc.Server):
             rpc.Server.start(self)
         except KeyboardInterrupt:
             # Put user into console where can look at state of server
-            if not self.config.catch_ctrlc:
+            if not self.config.catch_ctrlc or not self.verbose:
                 raise
             import code
             import readline
@@ -1330,9 +1331,9 @@ class NFS4Server(rpc.Server):
         sid, deleg, flags = self.open_file(existing, arg.owner,
                                     arg.share_access, arg.share_deny)
         env.set_cfh(existing, sid)
-        if 0 or env.session.client.config.debug_state:
-            print "+++ client(id=%i).state =" %  env.session.client.clientid
-            print env.session.client.state
+        if env.session.client.config.debug_state:
+            log_41.info("+++ client(id=%i).state = %r" %
+                        (env.session.client.clientid, env.session.client.state))
         res = OPEN4resok(sid, cinfo, flags, bitmask, deleg)
         return encode_status(NFS4_OK, res)
 
@@ -1452,14 +1453,13 @@ class NFS4Server(rpc.Server):
         ret_dict = {}
         info = nfs4lib.attr_info
         for attr in attrs:
-            print "handling fattr4_%s : " % nfs4lib.attr_name(attr),
             if attr not in info:
                 # Ignore unknown attributes
-                print "Unknown"
+                log_41.info("Skipping unknown attr: %s" % (attr,))
                 continue
             if not info[attr].readable:
                 # XXX How deal with write-only attrs?
-                print "Write only"
+                log_41.info("Skipping write only attr: %s" % (attr,))
                 continue
             # Attributes hide in different places, call the place 'base'
             if info[attr].from_fs:
@@ -1471,24 +1471,14 @@ class NFS4Server(rpc.Server):
             name = "fattr4_%s" % nfs4lib.attr_name(attr)
             if hasattr(base, name) and (obj.fs.fattr4_supported_attrs & 1<<attr): # STUB we should be able to remove hasattr
                 ret_dict[attr] = getattr(base, name)
-                print ret_dict[attr]
             else:
                 if ignore:
                     # Must ignore for GETATTR (and READDIR) per 15.1
-                    print "ignored"
-                    if name == "fattr4_mounted_on_fileid":
-                        print base == obj
-                        print base.fattr4_mounted_on_fileid
-                    if name == "fattr4_layout_blksize":
-                        print base == obj
-                        print hasattr(base, name)
-                        print obj.fs.fattr4_supported_attrs
-                        print 1<<attr
-                        print obj.fs.fattr4_supported_attrs & 1<<attr
+                    log_41.info("ignored attr %s" % (name,))
                     continue
                 else:
                     # This is for VERIFY/NVERIFY
-                    print "NOT SUPP"
+                    log_41.info("attr NOT SUPP %s" % (name,))
                     raise NFS4Error(NFS4ERR_ATTRNOTSUPP)
         obj.fattr4_rdattr_error = NFS4_OK # XXX STUB Handle correctly
         return ret_dict
@@ -1956,14 +1946,14 @@ class NFS4Server(rpc.Server):
                 calls.append(call)
             if arg.dir & xdrdef.sctrl_const.DIR_REPLY:
                 replies.append(reply)
-        print calls
-        print replies
+        #print calls
+        #print replies
         grabres = xdrdef.sctrl_type.GRABres(calls, replies)
         return xdrdef.sctrl_const.CTRLSTAT_OK, \
                xdrdef.sctrl_type.resdata_t(arg.ctrlop, grab = grabres)
 
     def ctrl_illegal(self, arg):
-        print "ILLEGAL"
+        #print "ILLEGAL"
         return xdrdef.sctrl_const.CTRLSTAT_ILLEGAL, xdrdef.sctrl_type.resdata_t(arg.ctrlop)
         
     def op_setclientid(self, arg, env):
@@ -2070,6 +2060,8 @@ def scan_options():
                     )
     p.add_option("-r", "--reset", action="store_true", default=False,
                  help="Reset and clear any disk-based filesystems")
+    p.add_option("-v", "--verbose", action="store_true", default=False,
+                 help="Print debug info to screen and enter interpreter on ^C")
     p.add_option("--use_block", action="store_true", default=False,
                  help="Mount a block-pnfs fs")
     p.add_option("--use_files", action="store_true", default=False,
@@ -2102,7 +2094,8 @@ if __name__ == "__main__":
         locking.DEBUG = True
     S = NFS4Server(port=opts.port,
                    is_mds=opts.use_block or opts.use_files,
-                   is_ds = opts.is_ds)
+                   is_ds = opts.is_ds,
+                   verbose = opts.verbose)
     read_exports(S, opts)
     if True:
         S.start()
diff --git a/nfs4.1/nfs4state.py b/nfs4.1/nfs4state.py
index 1294083..2f3cd59 100644
--- a/nfs4.1/nfs4state.py
+++ b/nfs4.1/nfs4state.py
@@ -13,7 +13,6 @@ import rpc
 import logging
 
 log = logging.getLogger("nfs.server.state")
-log.setLevel(10)
 
 POSIXLOCK = False
 
-- 
1.8.5.2 (Apple Git-48)


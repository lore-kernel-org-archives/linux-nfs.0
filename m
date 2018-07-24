Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:52764 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388391AbeGXIjR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:17 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 10/24] pynfs: python3 support plan: not equal op s/ <> / != /
Date: Tue, 24 Jul 2018 15:33:28 +0800
Message-Id: <20180724073342.5738-10-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/nfs4lib.py    | 4 ++--
 nfs4.0/nfs4server.py | 4 ++--
 nfs4.1/nfs4client.py | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index dddbf91..6f6d2f9 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -227,7 +227,7 @@ class CBServer(rpc.RPCServer):
             cbid = cmp4args.callback_ident
         except XDRError:
             return NFS4ERR_BADXDR, [], tag
-        if cmp4args.minorversion <> 0:
+        if cmp4args.minorversion != 0:
             return NFS4ERR_MINOR_VERS_MISMATCH, [], tag
         results = []
         ok = NFS4_OK
@@ -239,7 +239,7 @@ class CBServer(rpc.RPCServer):
                 resop4 = CB_ILLEGAL4res(NFS4ERR_OP_ILLEGAL)
                 result = nfs_cb_resop4(resop=OP_ILLEGAL, opcbillegal=resop4)
             results += [ result ]
-            if ok <> NFS4_OK:
+            if ok != NFS4_OK:
                 break
         return ok, results, tag
         
diff --git a/nfs4.0/nfs4server.py b/nfs4.0/nfs4server.py
index 18b0aad..753372e 100755
--- a/nfs4.0/nfs4server.py
+++ b/nfs4.0/nfs4server.py
@@ -171,7 +171,7 @@ class NFS4Server(rpc.RPCServer):
             return NFS4ERR_BADXDR, [], tag
         print("TCP NFSv4 COMPOUND call, tag: %s, n_ops: %d" % \
               (repr(tag), len(cmp4args.argarray)))
-        if cmp4args.minorversion <> 0:
+        if cmp4args.minorversion != 0:
             return NFS4ERR_MINOR_VERS_MISMATCH, [], tag
         if not verify_utf8(tag):
             return NFS4ERR_INVAL, [], tag
@@ -183,7 +183,7 @@ class NFS4Server(rpc.RPCServer):
             print("*** %s (%d) ***" % (opname, op.argop))
             ok, result = getattr(self, opname.lower())(op)
             results += [ result ]
-            if ok <> NFS4_OK:
+            if ok != NFS4_OK:
                 print(" ! error %s" % nfsstat4[ok])
                 break
         print("Replying. Status %s (%d)" % (nfsstat4[ok], ok))
diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 5288942..0588d7b 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -177,7 +177,7 @@ class NFS4Client(rpc.Client, rpc.Server):
     def op_cb_compound(self, args, cred):
         env = CompoundState(args, cred)
         # Check for problems with the compound itself
-        if args.minorversion <> 0:
+        if args.minorversion != 0:
             if args.minorversion not in self.minor_versions:
                 env.results.set_empty_return(NFS4ERR_MINOR_VERS_MISMATCH)
                 return env
-- 
2.17.1


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23881 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932641Ab2FAVPO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 17:15:14 -0400
From: andros@netapp.com
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [[PATCH resend] 6/6] PYNFS implement FREE_STATEID and TEST_STATEID operations
Date: Tue, 29 May 2012 18:11:29 -0400
Message-Id: <1338329489-29178-7-git-send-email-andros@netapp.com>
In-Reply-To: <1338329489-29178-1-git-send-email-andros@netapp.com>
References: <1338329489-29178-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 nfs4.1/nfs4server.py |   33 +++++++++++++++++++++++++++++++++
 nfs4.1/nfs4state.py  |   11 ++++++-----
 2 files changed, 39 insertions(+), 5 deletions(-)

diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
index b279292..8d0f112 100755
--- a/nfs4.1/nfs4server.py
+++ b/nfs4.1/nfs4server.py
@@ -1296,6 +1296,39 @@ class NFS4Server(rpc.Server):
         res = READ4resok(eof, data)
         return encode_status(NFS4_OK, res)
 
+    def op_free_stateid(self, arg, env):
+        check_session(env)
+        status = NFS4_OK
+        with find_state(env, arg.fsa_stateid, no_fh=True) as state:
+            try:
+                log_41.info("free_stateid found state DELETING state")
+                state.delete()
+            except NFS4Error, e:
+                log_41.info("free_stateid %s error: %d") % (arg.fsa_stateid, e.status)
+                status = e.status
+
+	res = FREE_STATEID4res(fsr_status = status)
+        return encode_status(NFS4_OK)
+
+    def op_test_stateid(self, arg, env):
+        check_session(env)
+	out = []
+        for stateid in arg.ts_stateids:
+            status = NFS4_OK
+            with find_state(env, stateid, no_fh=True) as state:
+                try:
+                    log_41.info("test_stateid found state")
+                    self.check_opsconfig(env, "test_stateid")
+                except NFS4Error, e:
+                    if (e.status == NFS4ERR_BAD_STATEID or e.status == NFS4ERR_ADMIN_REVOKED or e.status == NFS4ERR_OPENMODE):
+                        state.delete()
+                    status = e.status
+                finally:
+                    out.append(status)
+
+	res = TEST_STATEID4resok(tsr_status_codes = out)
+        return encode_status(NFS4_OK, res)
+
     def op_open(self, arg, env):
         self.check_opsconfig(env, "open")
         check_session(env)
diff --git a/nfs4.1/nfs4state.py b/nfs4.1/nfs4state.py
index e8445e3..a6b21f4 100644
--- a/nfs4.1/nfs4state.py
+++ b/nfs4.1/nfs4state.py
@@ -23,7 +23,7 @@ NORMAL, CB_INIT, CB_SENT, CB_RECEIVED, INVALID = range(5) # delegation/layout st
 DS_MAGIC = "\xa5" # STUB part of HACK code to ignore DS stateid
 
 @contextmanager
-def find_state(env, stateid, allow_0=True, allow_bypass=False):
+def find_state(env, stateid, allow_0=True, allow_bypass=False, no_fh=False):
     """Find the matching StateTableEntry, and manage its lock."""
     anon = False
     if env.is_ds:
@@ -57,10 +57,11 @@ def find_state(env, stateid, allow_0=True, allow_bypass=False):
         state = env.session.client.state.get(stateid.other, None)
         if state is None:
             raise NFS4Error(NFS4ERR_BAD_STATEID, tag="stateid not known")
-        if state.file != env.cfh:
-            raise NFS4Error(NFS4ERR_BAD_STATEID,
-                            tag="cfh %r does not match stateid %r" % 
-                            (state.file.fh, env.cfh.fh))
+        if no_fh == False:
+            if state.file != env.cfh:
+                raise NFS4Error(NFS4ERR_BAD_STATEID,
+                                tag="cfh %r does not match stateid %r" % 
+                                (state.file.fh, env.cfh.fh))
     state.lock.acquire()
     # It is possible that while waiting to get the lock, the state has been
     # removed.  In that case, the removal sets the invalid flag.
-- 
1.7.7.6


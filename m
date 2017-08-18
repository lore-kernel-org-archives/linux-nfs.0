Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55470 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750932AbdHRHOY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 03:14:24 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 18 Aug 2017 17:12:52 +1000
Subject: [PATCH 8/8] NFSv4.1: don't use machine credentials for CLOSE when
 using 'sec=sys'
Cc: linux-nfs@vger.kernel.org
Message-ID: <150304037211.30218.1236272488580678069.stgit@noble>
In-Reply-To: <150304014011.30218.1636255532744321171.stgit@noble>
References: <150304014011.30218.1636255532744321171.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An NFSv4.1 client might close a file after the user who opened it has
logged off.  In this case the user's credentials may no longer be
valid, if they are e.g. kerberos credentials that have expired.

NFSv4.1 has a mechanism to allow the client to use machine credentials
to close a file.  However due to a short-coming in the RFC, a CLOSE
with those credentials may not be possible if the file in question
isn't exported to the same security flavor - the required PUTFH must
be rejected when this is the case.

Specifically if a server and client support kerberos in general and
have used it to form a machine credential, but the file is only
exported to "sec=sys", a PUTFH with the machine credentials will fail,
so CLOSE is not possible.

As RPC_AUTH_UNIX (used by sec=sys) credentials can never expire, there
is no value in using the machine credential in place of them.
So in that case, just use the users credentials for CLOSE etc, as you would
in NFSv4.0

Signed-off-by: Neil Brown <neilb@suse.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/nfs4_fs.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 40bd05f05e74..ac4f10b7f6c1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -303,6 +303,17 @@ _nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
 	struct rpc_cred *newcred = NULL;
 	rpc_authflavor_t flavor;
 
+	if (sp4_mode == NFS_SP4_MACH_CRED_CLEANUP ||
+	    sp4_mode == NFS_SP4_MACH_CRED_PNFS_CLEANUP) {
+		/* Using machine creds for cleanup operations
+		 * is only relevent if the client credentials
+		 * might expire. So don't bother for
+		 * RPC_AUTH_UNIX.  If file was only exported to
+		 * sec=sys, the PUTFH would fail anyway.
+		 */
+		if ((*clntp)->cl_auth->au_flavor == RPC_AUTH_UNIX)
+			return false;
+	}
 	if (test_bit(sp4_mode, &clp->cl_sp4_flags)) {
 		spin_lock(&clp->cl_lock);
 		if (clp->cl_machine_cred != NULL)



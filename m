From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 6/7] nfsd: add support for NFSv4 callbacks over IPv6
Date: Wed, 12 Aug 2009 07:57:05 -0400
Message-ID: <1250078226-10511-7-git-send-email-jlayton@redhat.com>
References: <1250078226-10511-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35943 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184AbZHLL7L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Aug 2009 07:59:11 -0400
In-Reply-To: <1250078226-10511-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The framework to add this is all in place. Now, add the code to allow
support for establishing a callback channel on an IPv6 socket.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 96a7423..9ec0ca1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -901,9 +901,16 @@ static void
 gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 {
 	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
-
-	/* Currently, we only support tcp for the callback channel */
-	if ((se->se_callback_netid_len != 3) || memcmp((char *)se->se_callback_netid_val, "tcp", 3))
+	unsigned short expected_family;
+
+	/* Currently, we only support tcp and tcp6 for the callback channel */
+	if (se->se_callback_netid_len == 3 &&
+	    !memcmp(se->se_callback_netid_val, "tcp", 3))
+		expected_family = AF_INET;
+	else if (se->se_callback_netid_len == 4 &&
+		 !memcmp(se->se_callback_netid_val, "tcp6", 4))
+		expected_family = AF_INET6;
+	else
 		goto out_err;
 
 	cb->cb_addrlen = rpc_uaddr2sockaddr(se->se_callback_addr_val,
@@ -911,7 +918,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 					    (struct sockaddr *) &cb->cb_addr,
 					    sizeof(cb->cb_addr));
 
-	if (!cb->cb_addrlen || cb->cb_addr.ss_family != AF_INET)
+	if (!cb->cb_addrlen || cb->cb_addr.ss_family != expected_family)
 		goto out_err;
 
 	cb->cb_minorversion = 0;
-- 
1.6.0.6


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51809 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005Ab3FYShm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jun 2013 14:37:42 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/3] NFSv4.1 Do not overwrite negotiated session sizes
Date: Tue, 25 Jun 2013 14:37:33 -0400
Message-Id: <1372185454-1888-2-git-send-email-andros@netapp.com>
In-Reply-To: <1372185454-1888-1-git-send-email-andros@netapp.com>
References: <1372185454-1888-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfs4_init_session is called after CREATE_SESSION has set the ca_maxrequestsize
and ca_maxresponsesize values obtained from the server.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4session.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index c4e225e..7ac14cc 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -499,13 +499,11 @@ int nfs4_init_session(struct nfs_server *server)
 	session = clp->cl_session;
 	spin_lock(&clp->cl_lock);
 	if (test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state)) {
-		/* Initialise targets and channel attributes */
+		/* Initialise targets */
 		session->fc_target_max_rqst_sz = target_max_rqst_sz;
-		session->fc_attrs.max_rqst_sz = target_max_rqst_sz;
 		session->fc_target_max_resp_sz = target_max_resp_sz;
-		session->fc_attrs.max_resp_sz = target_max_resp_sz;
 	} else {
-		/* Just adjust the targets */
+		/* Adjust the targets and perhaps reset the session */
 		if (target_max_rqst_sz > session->fc_target_max_rqst_sz) {
 			session->fc_target_max_rqst_sz = target_max_rqst_sz;
 			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
-- 
1.7.11.7


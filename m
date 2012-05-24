Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31768 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755936Ab2EXTmU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 May 2012 15:42:20 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/2] nfsd: probe the back channel on new connections
Date: Thu, 24 May 2012 15:42:17 -0400
Message-Id: <1337888537-21754-2-git-send-email-dros@netapp.com>
In-Reply-To: <1337888537-21754-1-git-send-email-dros@netapp.com>
References: <1337888537-21754-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Initiate a CB probe when a new connection with the correct direction is added
to a session (IFF backchannel is marked as down).  Without this a
BIND_CONN_TO_SESSION has no effect on the internal backchannel state, which
causes the server to reply to every SEQUENCE op with the
SEQ4_STATUS_CB_PATH_DOWN flag set until DESTROY_SESSION.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
Hey Bruce -
 In an earlier thread I mentioned that I was setting the backchannel state to
CB_UNKNOWN to clear the SEQ4_STATUS flag, but this was wrong - I don't believe
it would ever change (to CB_UP/CB_DOWN).  This patch seems like the right way
to handle the internal backchannel state.

Also, I'm a bit confused as how we're supposed to maintain atomicity around
cl_cb_state:

from nfs4callback.c:nfsd4_probe_callback():
  /* XXX: atomicity?  Also, should we be using cl_flags? */
  clp->cl_cb_state = NFSD4_CB_UNKNOWN;

and there are several places that check the value of cl_cb_state without holding
a lock (as far as I can tell).

 fs/nfsd/nfs4state.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9afc902..99f092e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -862,6 +862,11 @@ static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses,
 	if (ret)
 		/* oops; xprt is already down: */
 		nfsd4_conn_lost(&conn->cn_xpt_user);
+	if (ses->se_client->cl_cb_state == NFSD4_CB_DOWN &&
+		dir & NFS4_CDFC4_BACK) {
+		/* callback channel may be back up */
+		nfsd4_probe_callback(ses->se_client);
+	}
 	return nfs_ok;
 }
 
-- 
1.7.4.4


From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 7/8] NFSv4.1: Don't call nfs4_schedule_state_recovery()
 unnecessarily
Date: Mon, 25 Jan 2010 16:57:35 -0500
Message-ID: <20100125215735.14716.86605.stgit@localhost.localdomain>
References: <20100125215734.14716.19614.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8049 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764Ab0AYWEK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:04:10 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0PM4A0v014296
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 14:04:10 -0800 (PST)
In-Reply-To: <20100125215734.14716.19614.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, nfs4_handle_exception() will call it twice if called with an
error of -NFS4ERR_STALE_CLIENTID, -NFS4ERR_STALE_STATEID or
-NFS4ERR_EXPIRED.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index be044b5..afbfe67 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -256,12 +256,8 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 			ret = nfs4_wait_clnt_recover(clp);
 			if (ret == 0)
 				exception->retry = 1;
-#if !defined(CONFIG_NFS_V4_1)
 			break;
-#else /* !defined(CONFIG_NFS_V4_1) */
-			if (!nfs4_has_session(server->nfs_client))
-				break;
-			/* FALLTHROUGH */
+#if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
 		case -NFS4ERR_BAD_HIGH_SLOT:
@@ -274,7 +270,7 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 			nfs4_schedule_state_recovery(clp);
 			exception->retry = 1;
 			break;
-#endif /* !defined(CONFIG_NFS_V4_1) */
+#endif /* defined(CONFIG_NFS_V4_1) */
 		case -NFS4ERR_FILE_OPEN:
 			if (exception->timeout > HZ) {
 				/* We have retried a decent amount, time to


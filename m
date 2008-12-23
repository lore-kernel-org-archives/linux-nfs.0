From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 46/69] NFSv4: Fix an infinite loop in the NFS state
 recovery code
Date: Tue, 23 Dec 2008 18:02:19 -0500
Message-ID: <20081223230219.13743.37658.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1640 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752772AbYLWXYm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:42 -0500
Received: from sacrsexc1-prd.hq.netapp.com ([10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOc0X006400
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Marten Gajda <marten.gajda-PdBPhxpS/JMDwj1Imt9BnQ@public.gmane.org> states:

I tracked the problem down to the function nfs4_do_open_expired.
Within this function _nfs4_open_expired is called and may return
-NFS4ERR_DELAY. When a further call to _nfs4_open_expired is
executed and does not return -NFS4ERR_DELAY the "exception.retry"
variable is not reset to 0, causing the loop to iterate again
(and as long as err != -NFS4ERR_DELAY, probably forever)

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e8df52d..49eebe2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1104,8 +1104,9 @@ static inline int nfs4_do_open_expired(struct nfs_open_context *ctx, struct nfs4
 
 	do {
 		err = _nfs4_open_expired(ctx, state);
-		if (err == -NFS4ERR_DELAY)
-			nfs4_handle_exception(server, err, &exception);
+		if (err != -NFS4ERR_DELAY)
+			break;
+		nfs4_handle_exception(server, err, &exception);
 	} while (exception.retry);
 	return err;
 }


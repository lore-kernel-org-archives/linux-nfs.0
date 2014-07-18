Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:38133 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761804AbaGRPNx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 11:13:53 -0400
Received: by mail-qg0-f44.google.com with SMTP id e89so3253877qgf.17
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jul 2014 08:13:53 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v4 07/10] nfsd: drop unused stp arg to alloc_init_deleg
Date: Fri, 18 Jul 2014 11:13:33 -0400
Message-Id: <1405696416-32585-8-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 40def186ee50..3e761ea48a70 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -568,7 +568,7 @@ static void block_delegations(struct knfsd_fh *fh)
 }
 
 static struct nfs4_delegation *
-alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh)
+alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh)
 {
 	struct nfs4_delegation *dp;
 	long n;
@@ -3650,7 +3650,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 		default:
 			goto out_no_deleg;
 	}
-	dp = alloc_init_deleg(oo->oo_owner.so_client, stp, fh);
+	dp = alloc_init_deleg(oo->oo_owner.so_client, fh);
 	if (dp == NULL)
 		goto out_no_deleg;
 	status = nfs4_set_delegation(dp, stp->st_file);
-- 
1.9.3


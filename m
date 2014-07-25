Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:55009 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759947AbaGYLet (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2014 07:34:49 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so4825694qge.11
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 04:34:48 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v6 5/9] nfsd: drop unused stp arg to alloc_init_deleg
Date: Fri, 25 Jul 2014 07:34:23 -0400
Message-Id: <1406288067-20663-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
References: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b421b51c3a9e..049ef2ce72bf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -579,7 +579,7 @@ static void block_delegations(struct knfsd_fh *fh)
 }
 
 static struct nfs4_delegation *
-alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh)
+alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh)
 {
 	struct nfs4_delegation *dp;
 	long n;
@@ -3649,7 +3649,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
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


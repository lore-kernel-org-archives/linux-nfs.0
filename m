Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33442 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751676AbcLAWGf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:06:35 -0500
Received: by mail-io0-f194.google.com with SMTP id j92so3869329ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:06:35 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4: Don't check file access when reclaiming state
Date: Thu,  1 Dec 2016 17:06:28 -0500
Message-Id: <20161201220632.12754-2-trond.myklebust@primarydata.com>
In-Reply-To: <20161201220632.12754-1-trond.myklebust@primarydata.com>
References: <20161201220632.12754-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're reclaiming state after a reboot, or as part of returning a
delegation, we don't need to check access modes again.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 241da19b7da4..b582df89c083 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1221,6 +1221,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	atomic_inc(&sp->so_count);
 	p->o_arg.open_flags = flags;
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
+	p->o_arg.claim = nfs4_map_atomic_open_claim(server, claim);
 	p->o_arg.share_access = nfs4_map_atomic_open_share(server,
 			fmode, flags);
 	/* don't put an ACCESS op in OPEN compound if O_EXCL, because ACCESS
@@ -1228,8 +1229,16 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	if (!(flags & O_EXCL)) {
 		/* ask server to check for all possible rights as results
 		 * are cached */
-		p->o_arg.access = NFS4_ACCESS_READ | NFS4_ACCESS_MODIFY |
-				  NFS4_ACCESS_EXTEND | NFS4_ACCESS_EXECUTE;
+		switch (p->o_arg.claim) {
+		default:
+			break;
+		case NFS4_OPEN_CLAIM_NULL:
+		case NFS4_OPEN_CLAIM_FH:
+			p->o_arg.access = NFS4_ACCESS_READ |
+				NFS4_ACCESS_MODIFY |
+				NFS4_ACCESS_EXTEND |
+				NFS4_ACCESS_EXECUTE;
+		}
 	}
 	p->o_arg.clientid = server->nfs_client->cl_clientid;
 	p->o_arg.id.create_time = ktime_to_ns(sp->so_seqid.create_time);
@@ -1239,7 +1248,6 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.bitmask = nfs4_bitmask(server, label);
 	p->o_arg.open_bitmap = &nfs4_fattr_bitmap[0];
 	p->o_arg.label = nfs4_label_copy(p->a_label, label);
-	p->o_arg.claim = nfs4_map_atomic_open_claim(server, claim);
 	switch (p->o_arg.claim) {
 	case NFS4_OPEN_CLAIM_NULL:
 	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
-- 
2.9.3


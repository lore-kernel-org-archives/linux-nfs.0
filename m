Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:6416 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864Ab3HVA03 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:26:29 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/6] NFSv4: Deal with a sparse warning in nfs4_opendata_alloc
Date: Wed, 21 Aug 2013 20:26:22 -0400
Message-ID: <1377131186-40249-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131186-40249-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131186-40249-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f50ad28..155c2fa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -933,15 +933,11 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 		p->o_arg.fh = NFS_FH(dentry->d_inode);
 	}
 	if (attrs != NULL && attrs->ia_valid != 0) {
-		__be32 verf[2];
-
 		p->o_arg.u.attrs = &p->attrs;
 		memcpy(&p->attrs, attrs, sizeof(p->attrs));
 
-		verf[0] = jiffies;
-		verf[1] = current->pid;
-		memcpy(p->o_arg.u.verifier.data, verf,
-				sizeof(p->o_arg.u.verifier.data));
+		p->o_arg.u.verifier.data[0] = cpu_to_be32(jiffies);
+		p->o_arg.u.verifier.data[1] = cpu_to_be32(current->pid);
 	}
 	p->c_arg.fh = &p->o_res.fh;
 	p->c_arg.stateid = &p->o_res.stateid;
-- 
1.8.3.1


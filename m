Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14632 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932608Ab2JCXbb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Oct 2012 19:31:31 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4 set open access operation call flag in nfs4_init_opendata_res
Date: Wed,  3 Oct 2012 02:39:34 -0400
Message-Id: <1349246374-2244-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfs4_open_recover_helper zeros the nfs4_opendata result structures, removing
the result access_request information which leads to an XDR decode error.

Move the setting of the result access_request field to nfs4_init_opendata_res
which sets all the other required nfs4_opendata result fields and is shared
between the open and recover open paths.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2b62e3f..68b21d8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -840,6 +840,7 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 	p->o_res.seqid = p->o_arg.seqid;
 	p->c_res.seqid = p->c_arg.seqid;
 	p->o_res.server = p->o_arg.server;
+	p->o_res.access_request = p->o_arg.access;
 	nfs_fattr_init(&p->f_attr);
 	nfs_fattr_init_names(&p->f_attr, &p->owner_name, &p->group_name);
 }
@@ -875,7 +876,6 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 		 * are cached */
 		p->o_arg.access = NFS4_ACCESS_READ | NFS4_ACCESS_MODIFY |
 				  NFS4_ACCESS_EXTEND | NFS4_ACCESS_EXECUTE;
-		p->o_res.access_request = p->o_arg.access;
 	}
 	p->o_arg.clientid = server->nfs_client->cl_clientid;
 	p->o_arg.id.create_time = ktime_to_ns(sp->so_seqid.create_time);
-- 
1.7.6.4


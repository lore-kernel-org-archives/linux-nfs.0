Return-Path: <smayhew@redhat.com>
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com,
	anna.schumaker@netapp.com
Cc: bcodding@redhat.com,
	dwysocha@redhat.com,
	fsorenso@redhat.com,
	linux-nfs@vger.kernel.org
Subject: [PATCH] nfs/pnfs: fix nfs_direct_req ref leak when i/o falls back to the mds
Date: Wed, 13 Dec 2017 11:15:55 -0500
Message-Id: <20171213161555.27993-1-smayhew@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

Currently when falling back to doing I/O through the MDS (via
pnfs_{read|write}_through_mds), the client frees the nfs_pgio_header
without releasing the reference taken on the dreq
via pnfs_generic_pg_{read|write}pages -> nfs_pgheader_init ->
nfs_direct_pgio_init.  It then takes another reference on the dreq via
nfs_generic_pg_pgios -> nfs_pgheader_init -> nfs_direct_pgio_init and
as a result the requester will become stuck in inode_dio_wait.  Once
that happens, other processes accessing the inode will become stuck as
well.

Moving the init_hdr call down to nfs_initiate_pgio ensures we take the
reference on the dreq only once.

This can be reproduced (sometimes) by performing "storage failover
takeover" commands on NetApp filer while doing direct I/O from a client.

This can also be reproduced using SystemTap to simulate a failure while
doing direct I/O from a client (from Dave Wysochanski
<dwysocha@redhat.com>):

stap -v -g -e 'probe module("nfs_layout_nfsv41_files").function("nfs4_fl_prepare_ds").return { $return=NULL; exit(); }'

Suggested-by: Benjamin Coddington <bcodding@redhat.com>
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/pagelist.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index d0543e1..d478c19 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -54,9 +54,6 @@ void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 	hdr->dreq = desc->pg_dreq;
 	hdr->release = release;
 	hdr->completion_ops = desc->pg_completion_ops;
-	if (hdr->completion_ops->init_hdr)
-		hdr->completion_ops->init_hdr(hdr);
-
 	hdr->pgio_mirror_idx = desc->pg_mirror_idx;
 }
 EXPORT_SYMBOL_GPL(nfs_pgheader_init);
@@ -607,6 +604,9 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
 	};
 	int ret = 0;
 
+	if (hdr->completion_ops->init_hdr)
+		hdr->completion_ops->init_hdr(hdr);
+
 	hdr->rw_ops->rw_initiate(hdr, &msg, rpc_ops, &task_setup_data, how);
 
 	dprintk("NFS: initiated pgio call "
-- 
2.9.5

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35586 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752127AbcHKRg2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Aug 2016 13:36:28 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@primarydata.com>,
        hch@lst.de
Subject: [PATCH] nfsd: don't set a FL_LAYOUT lease for flexfiles layouts
Date: Thu, 11 Aug 2016 13:36:22 -0400
Message-Id: <1470936982-14409-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently can hit a deadlock (of sorts) when trying to use flexfiles
layouts with XFS. XFS will call break_layout when something wants to
write to the file. In the case of the (super-simple) flexfiles layout
driver in knfsd, the MDS and DS are the same machine.

The client can get a layout and then issue a v3 write to do its I/O. XFS
will then call xfs_break_layouts, which will cause a CB_LAYOUTRECALL to
be issued to the client. The client however can't return the layout
until the v3 WRITE completes, but XFS won't allow the write to proceed
until the layout is returned.

Christoph says:

    XFS only cares about block-like layouts where the client has direct
    access to the file blocks.  I'd need to look how to propagate the
    flag into break_layout, but in principle we don't need to do any
    recalls on truncate ever for file and flexfile layouts.

If we're never going to recall the layout, then we don't even need to
set the lease at all. Just skip doing so on flexfiles layouts by
adding a new flag to struct nfsd4_layout_ops and skipping the lease
setting and removal when that flag is true.

Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/flexfilelayout.c | 1 +
 fs/nfsd/nfs4layouts.c    | 6 +++++-
 fs/nfsd/pnfs.h           | 1 +
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/flexfilelayout.c b/fs/nfsd/flexfilelayout.c
index df880e9fa71f..b67287383010 100644
--- a/fs/nfsd/flexfilelayout.c
+++ b/fs/nfsd/flexfilelayout.c
@@ -126,6 +126,7 @@ nfsd4_ff_proc_getdeviceinfo(struct super_block *sb, struct svc_rqst *rqstp,
 const struct nfsd4_layout_ops ff_layout_ops = {
 	.notify_types		=
 			NOTIFY_DEVICEID4_DELETE | NOTIFY_DEVICEID4_CHANGE,
+	.disable_recalls	= true,
 	.proc_getdeviceinfo	= nfsd4_ff_proc_getdeviceinfo,
 	.encode_getdeviceinfo	= nfsd4_ff_encode_getdeviceinfo,
 	.proc_layoutget		= nfsd4_ff_proc_layoutget,
diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 2be9602b0221..42aace4fc4c8 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -174,7 +174,8 @@ nfsd4_free_layout_stateid(struct nfs4_stid *stid)
 	list_del_init(&ls->ls_perfile);
 	spin_unlock(&fp->fi_lock);
 
-	vfs_setlease(ls->ls_file, F_UNLCK, NULL, (void **)&ls);
+	if (!nfsd4_layout_ops[ls->ls_layout_type]->disable_recalls)
+		vfs_setlease(ls->ls_file, F_UNLCK, NULL, (void **)&ls);
 	fput(ls->ls_file);
 
 	if (ls->ls_recalled)
@@ -189,6 +190,9 @@ nfsd4_layout_setlease(struct nfs4_layout_stateid *ls)
 	struct file_lock *fl;
 	int status;
 
+	if (nfsd4_layout_ops[ls->ls_layout_type]->disable_recalls)
+		return 0;
+
 	fl = locks_alloc_lock();
 	if (!fl)
 		return -ENOMEM;
diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
index 0c2a716e8741..d27a5aa60022 100644
--- a/fs/nfsd/pnfs.h
+++ b/fs/nfsd/pnfs.h
@@ -19,6 +19,7 @@ struct nfsd4_deviceid_map {
 
 struct nfsd4_layout_ops {
 	u32		notify_types;
+	bool		disable_recalls;
 
 	__be32 (*proc_getdeviceinfo)(struct super_block *sb,
 			struct svc_rqst *rqstp,
-- 
2.7.4


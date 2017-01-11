Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36260 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752099AbdAKWHd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jan 2017 17:07:33 -0500
Received: by mail-io0-f196.google.com with SMTP id q20so558804ioi.3
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jan 2017 14:07:13 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFSv4: Call update_changeattr() from _nfs4_proc_open only if a file was created
Date: Wed, 11 Jan 2017 17:07:07 -0500
Message-Id: <20170111220709.19405-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't want to invalidate the directory attribute and data cache unless we
know that a file was created, or the change attribute differs from the one
in our cache.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6dcbc5defb7a..176561a0fe0d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2391,11 +2391,12 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 	nfs_fattr_map_and_free_names(server, &data->f_attr);
 
 	if (o_arg->open_flags & O_CREAT) {
-		update_changeattr(dir, &o_res->cinfo);
 		if (o_arg->open_flags & O_EXCL)
 			data->file_created = 1;
 		else if (o_res->cinfo.before != o_res->cinfo.after)
 			data->file_created = 1;
+		if (data->file_created || dir->i_version != o_res->cinfo.after)
+			update_changeattr(dir, &o_res->cinfo);
 	}
 	if ((o_res->rflags & NFS4_OPEN_RESULT_LOCKTYPE_POSIX) == 0)
 		server->caps &= ~NFS_CAP_POSIX_LOCK;
-- 
2.9.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35836 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750843AbdALXCq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 18:02:46 -0500
Received: by mail-it0-f66.google.com with SMTP id 203so3399650ith.2
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jan 2017 15:02:45 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/4] NFSv4: Call update_changeattr() from _nfs4_proc_open only if a file was created
Date: Thu, 12 Jan 2017 18:02:37 -0500
Message-Id: <20170112230240.7730-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170112230240.7730-1-trond.myklebust@primarydata.com>
References: <20170112230240.7730-1-trond.myklebust@primarydata.com>
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
index 700ed1fc1075..4010c33151ad 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2390,11 +2390,12 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
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


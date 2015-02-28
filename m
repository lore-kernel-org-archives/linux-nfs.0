Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:34073 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbbB1DQS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2015 22:16:18 -0500
Received: by igal13 with SMTP id l13so4890882iga.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Feb 2015 19:16:18 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: nfs4_open_recover_helper() must set share access
Date: Fri, 27 Feb 2015 22:16:14 -0500
Message-Id: <1425093374-6034-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The share access mode is now specified as an argument in the nfs4_opendata,
and so nfs4_open_recover_helper() needs to call nfs4_map_atomic_open_share()
in order to set it.

Fixes: 6ae373394c42 ("NFSv4.1: Ask for no delegation on OPEN if using O_DIRECT")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 88180ac5ea0e..4e41340e957d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1552,6 +1552,9 @@ static int nfs4_open_recover_helper(struct nfs4_opendata *opendata, fmode_t fmod
 
 	opendata->o_arg.open_flags = 0;
 	opendata->o_arg.fmode = fmode;
+	opendata->o_arg.share_access = nfs4_map_atomic_open_share(
+			NFS_SB(opendata->dentry->d_sb),
+			fmode, 0);
 	memset(&opendata->o_res, 0, sizeof(opendata->o_res));
 	memset(&opendata->c_res, 0, sizeof(opendata->c_res));
 	nfs4_init_opendata_res(opendata);
-- 
2.1.0


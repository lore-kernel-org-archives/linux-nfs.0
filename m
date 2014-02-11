Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:53167 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932169AbaBKThR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 14:37:17 -0500
Received: by mail-ig0-f174.google.com with SMTP id hl1so9526080igb.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 11:37:17 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFSv4.1: Allow parallel OPEN requests
Date: Tue, 11 Feb 2014 14:37:07 -0500
Message-Id: <1392147428-23087-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1392147428-23087-4-git-send-email-trond.myklebust@primarydata.com>
References: <1392147428-23087-1-git-send-email-trond.myklebust@primarydata.com>
 <1392147428-23087-2-git-send-email-trond.myklebust@primarydata.com>
 <1392147428-23087-3-git-send-email-trond.myklebust@primarydata.com>
 <1392147428-23087-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Enable parallel OPEN requests for the case of NFSv4.1. Please note that
OPENs are still completely serialised w.r.t. OPEN_DOWNGRADE and CLOSE.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 96e0bd42f38c..4eb78f6c3623 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1006,6 +1006,8 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.clientid = server->nfs_client->cl_clientid;
 	p->o_arg.id.create_time = ktime_to_ns(sp->so_seqid.create_time);
 	p->o_arg.id.uniquifier = sp->so_seqid.owner_id;
+	if (server->caps & NFS_CAP_STATEID_NFSV41)
+		p->o_arg.seqid->wait.shared = 1;
 	p->o_arg.name = &dentry->d_name;
 	p->o_arg.server = server;
 	p->o_arg.bitmask = nfs4_bitmask(server, label);
-- 
1.8.5.3


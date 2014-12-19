Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:43676 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbaLSUoV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2014 15:44:21 -0500
Received: by mail-ig0-f176.google.com with SMTP id l13so1379444iga.9
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2014 12:44:21 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 2/2] NFSv4: Remove incorrect check in can_open_delegated()
Date: Fri, 19 Dec 2014 15:44:05 -0500
Message-Id: <1419021845-96747-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1419021845-96747-1-git-send-email-trond.myklebust@primarydata.com>
References: <1419021845-96747-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <CAHQdGtTqO02BWwTOsXn2s641_KBdawBexG5+kGwmJKWaAmewtA@mail.gmail.com>
References: <CAHQdGtTqO02BWwTOsXn2s641_KBdawBexG5+kGwmJKWaAmewtA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove an incorrect check for NFS_DELEGATION_NEED_RECLAIM in
can_open_delegated(). We are allowed to cache opens even in
a situation where we're doing reboot recovery.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8514b59a8c30..002c7dfedb08 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1119,8 +1119,6 @@ static int can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode)
 		return 0;
 	if ((delegation->type & fmode) != fmode)
 		return 0;
-	if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
-		return 0;
 	if (test_bit(NFS_DELEGATION_RETURNING, &delegation->flags))
 		return 0;
 	nfs_mark_delegation_referenced(delegation);
-- 
2.1.0


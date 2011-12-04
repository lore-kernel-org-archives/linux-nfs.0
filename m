Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41971 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684Ab1LDNr7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:47:59 -0500
Received: by eaak14 with SMTP id k14so3592866eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:47:57 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/13] SQUASHME: pnfsd: add missing nfs4_unlock_state in nfs4_pnfs_return_layout
Date: Sun,  4 Dec 2011 15:47:49 +0200
Message-Id: <1323006469-13460-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index d77df33..42e2bb0 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -989,6 +989,7 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	if (lrp->args.lr_return_type == RETURN_FILE) {
 		fp = find_file(ino);
 		if (!fp) {
+			nfs4_unlock_state();
 			dprintk("%s: RETURN_FILE: no nfs4_file for ino %p:%lu\n",
 				__func__, ino, ino ? ino->i_ino : 0L);
 			/* If we had a layout on the file the nfs4_file would
-- 
1.7.6


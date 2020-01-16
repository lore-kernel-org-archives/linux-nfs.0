Return-Path: <SRS0=2HRz=3F=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C61DAC33CB3
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Jan 2020 18:31:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A397F2077B
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Jan 2020 18:31:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1579199463;
	bh=mLDp92O2C3qsOQkY4HX4KZejpeluTzoGMiIMT5MAAvs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=fh7F/1q75BI7/+zZttDx1WkpdqQixvekCpQ3KIeMZ8GZ0+l8L0DzzIKhAuwvi9REq
	 QSYf5r+qBa65o6Q5LryxTVTOn+uXBcmk67apUgVjFdB8KOvqH1AeRdZt2ozQTS2mh6
	 HrfQ38U2Tai6qRYIb/m2G+2V6bPe0h5JIZ6oHy8o=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392176AbgAPSbC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 16 Jan 2020 13:31:02 -0500
Received: from mail.kernel.org ([198.145.29.99]:33126 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2391940AbgAPRZZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Jan 2020 12:25:25 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 88BBB246CE;
        Thu, 16 Jan 2020 17:25:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1579195524;
        bh=mLDp92O2C3qsOQkY4HX4KZejpeluTzoGMiIMT5MAAvs=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=bDNn2xxOTvSDUXpng/IxLk7xA98FZmuR1/poBbvF5ONqMwIZS/I4PEtGCOlnFIBvj
         4TOJen7BIWU4O4FY7kNY9JF3cji8xlNVj5e+6HSvgqmQ7tRP/9alinnm104Z28Dbzl
         LzRFmlifFPv3sPnFmEhqDrBRjzKYw25uFBRewGRQ=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.14 121/371] NFS/pnfs: Bulk destroy of layouts needs to be safe w.r.t. umount
Date:   Thu, 16 Jan 2020 12:19:53 -0500
Message-Id: <20200116172403.18149-64-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200116172403.18149-1-sashal@kernel.org>
References: <20200116172403.18149-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit 5085607d209102b37b169bc94d0aa39566a9842a ]

If a bulk layout recall or a metadata server reboot coincides with a
umount, then holding a reference to an inode is unsafe unless we
also hold a reference to the super block.

Fixes: fd9a8d7160937 ("NFSv4.1: Fix bulk recall and destroy of layouts")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/pnfs.c | 33 +++++++++++++++++++++++----------
 fs/nfs/pnfs.h |  1 +
 2 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ec04cce31814..83abf3dd7351 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -725,22 +725,35 @@ static int
 pnfs_layout_bulk_destroy_byserver_locked(struct nfs_client *clp,
 		struct nfs_server *server,
 		struct list_head *layout_list)
+	__must_hold(&clp->cl_lock)
+	__must_hold(RCU)
 {
 	struct pnfs_layout_hdr *lo, *next;
 	struct inode *inode;
 
 	list_for_each_entry_safe(lo, next, &server->layouts, plh_layouts) {
-		if (test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags))
+		if (test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) ||
+		    test_bit(NFS_LAYOUT_INODE_FREEING, &lo->plh_flags) ||
+		    !list_empty(&lo->plh_bulk_destroy))
 			continue;
+		/* If the sb is being destroyed, just bail */
+		if (!nfs_sb_active(server->super))
+			break;
 		inode = igrab(lo->plh_inode);
-		if (inode == NULL)
-			continue;
-		list_del_init(&lo->plh_layouts);
-		if (pnfs_layout_add_bulk_destroy_list(inode, layout_list))
-			continue;
-		rcu_read_unlock();
-		spin_unlock(&clp->cl_lock);
-		iput(inode);
+		if (inode != NULL) {
+			list_del_init(&lo->plh_layouts);
+			if (pnfs_layout_add_bulk_destroy_list(inode,
+						layout_list))
+				continue;
+			rcu_read_unlock();
+			spin_unlock(&clp->cl_lock);
+			iput(inode);
+		} else {
+			rcu_read_unlock();
+			spin_unlock(&clp->cl_lock);
+			set_bit(NFS_LAYOUT_INODE_FREEING, &lo->plh_flags);
+		}
+		nfs_sb_deactive(server->super);
 		spin_lock(&clp->cl_lock);
 		rcu_read_lock();
 		return -EAGAIN;
@@ -778,7 +791,7 @@ pnfs_layout_free_bulk_destroy_list(struct list_head *layout_list,
 		/* Free all lsegs that are attached to commit buckets */
 		nfs_commit_inode(inode, 0);
 		pnfs_put_layout_hdr(lo);
-		iput(inode);
+		nfs_iput_and_deactive(inode);
 	}
 	return ret;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 87f144f14d1e..965d657086c8 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -99,6 +99,7 @@ enum {
 	NFS_LAYOUT_RETURN_REQUESTED,	/* Return this layout ASAP */
 	NFS_LAYOUT_INVALID_STID,	/* layout stateid id is invalid */
 	NFS_LAYOUT_FIRST_LAYOUTGET,	/* Serialize first layoutget */
+	NFS_LAYOUT_INODE_FREEING,	/* The inode is being freed */
 };
 
 enum layoutdriver_policy_flags {
-- 
2.20.1


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62013 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756991Ab2ARERh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 23:17:37 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 09/10] NFS: Ensure that mmapped pages remain stable during writeback
Date: Tue, 17 Jan 2012 23:17:12 -0500
Message-Id: <1326860233-27947-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1326860233-27947-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1326860233-27947-1-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-2-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-3-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-4-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-5-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-6-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-7-git-send-email-Trond.Myklebust@netapp.com>
 <1326860233-27947-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that nfs_vm_page_mkwrite() waits for the page writeback to
complete before the application is allowed to modify page
contents.
The main reason for wanting to do this in NFS is to ensure that the
server doesn't get confused if we have to resend the RPC request
due to a dropped/missed reply.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/file.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c43a452..4fdaaa6 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -530,6 +530,8 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (mapping != dentry->d_inode->i_mapping)
 		goto out_unlock;
 
+	wait_on_page_writeback(page);
+
 	pagelen = nfs_page_length(page);
 	if (pagelen == 0)
 		goto out_unlock;
-- 
1.7.7.5


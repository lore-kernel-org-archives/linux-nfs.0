Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52661 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181Ab1ADDHE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 22:07:04 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] locks: minor setlease cleanup
Date: Mon,  3 Jan 2011 22:06:59 -0500
Message-Id: <1294110419-3105-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1294110419-3105-1-git-send-email-bfields@redhat.com>
References: <1294110419-3105-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 5cb6506..feaac63 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1399,7 +1399,7 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 	for (before = &inode->i_flock;
 			((fl = *before) != NULL) && IS_LEASE(fl);
 			before = &fl->fl_next) {
-		if (fl->fl_file == lease->fl_file)
+		if (fl->fl_file == filp)
 			my_before = before;
 		else if (fl->fl_type == (F_INPROGRESS | F_UNLCK))
 			/*
-- 
1.7.1


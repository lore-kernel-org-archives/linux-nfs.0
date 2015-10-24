Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33611 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715AbbJXP33 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 11:29:29 -0400
Received: by pabrc13 with SMTP id rc13so144300382pab.0
        for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2015 08:29:28 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        "Darrick J. Wong" <darrick.wong@oracle.com>, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-cifs@vger.kernel.org,
        Steve French <steve.french@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 6/9] cifs: remove private handler of BTRFS_IOC_CLONE
Date: Sun, 25 Oct 2015 07:17:13 +0800
Message-Id: <1445728636-10109-7-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
References: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

BTRFS_IOC_CLONE/BTRFS_IOC_CLONE_RANGE is now handled
by generic layer and goes through the .copy_file_range
method.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/cifs/ioctl.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/cifs/ioctl.c b/fs/cifs/ioctl.c
index bbab940..5dfc63a 100644
--- a/fs/cifs/ioctl.c
+++ b/fs/cifs/ioctl.c
@@ -267,9 +267,6 @@ long cifs_ioctl(struct file *filep, unsigned int command, unsigned long arg)
 		case CIFS_IOC_COPYCHUNK_FILE:
 			rc = cifs_ioctl_clone(xid, filep, arg, 0, 0, 0, false);
 			break;
-		case BTRFS_IOC_CLONE:
-			rc = cifs_ioctl_clone(xid, filep, arg, 0, 0, 0, true);
-			break;
 		case CIFS_IOC_SET_INTEGRITY:
 			if (pSMBFile == NULL)
 				break;
-- 
1.8.3.1


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw1.uni-kl.de ([131.246.120.220]:42877 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025Ab2AIKQu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 05:16:50 -0500
Subject: [PATCH 4 1/4] Add new FMODE flags: FMODE_32bithash and FMODE_64bithash
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com, bfields@redhat.com,
        sandeen@redhat.com, adilger@whamcloud.com
Date: Mon, 09 Jan 2012 11:16:33 +0100
Message-ID: <20120109101633.2218398.60217.stgit@localhost.localdomain>
In-Reply-To: <20120109101628.2218398.94904.stgit@localhost.localdomain>
References: <20120109101628.2218398.94904.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Those flags are supposed to be set by NFS readdir() to tell ext3/ext4
to 32bit (NFSv2) or 64bit hash values (offsets) in seekdir().

Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
---
 include/linux/fs.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7aacf31..b158386 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -92,6 +92,11 @@ struct inodes_stat_t {
 /* File is opened using open(.., 3, ..) and is writeable only for ioctls
    (specialy hack for floppy.c) */
 #define FMODE_WRITE_IOCTL	((__force fmode_t)0x100)
+/* 32bit hashes as llseek() offset (for directories) */
+#define FMODE_32BITHASH         ((__force fmode_t)0x200)
+/* 64bit hashes as llseek() offset (for directories) */
+#define FMODE_64BITHASH         ((__force fmode_t)0x400)
+
 
 /*
  * Don't update ctime and mtime.


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:37959 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080Ab1HHPiA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2011 11:38:00 -0400
Subject: [PATCH 1/4] Add new FMODE flags: FMODE_32bithash and FMODE_64bithash
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: hch@infradead.org, yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org,
        tytso@mit.edu, adilger@whamcloud.com
Date: Mon, 08 Aug 2011 17:37:58 +0200
Message-ID: <20110808153758.1872437.35029.stgit@fsdevel3>
In-Reply-To: <20110808153432.1872437.85783.stgit@fsdevel3>
References: <20110808153432.1872437.85783.stgit@fsdevel3>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Those flags are supposed to be set by NFS readdir() to tell ext3/ext4
to 32bit (NFSv2) or 64bit hash values (offsets) in seekdir().

Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
---
 include/linux/fs.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 178cdb4..18d40ae 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -91,6 +91,11 @@ struct inodes_stat_t {
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


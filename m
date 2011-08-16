Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:53102 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373Ab1HPLyL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 07:54:11 -0400
Subject: [PATCH 3 1/4] Add new FMODE flags: FMODE_32bithash and FMODE_64bithash
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: bfields@fieldses.org, tytso@mit.edu, bernd.schubert@fastmail.fm,
        hch@infradead.org, adilger@whamcloud.com, yong.fan@whamcloud.com,
        linux-fsdevel@vger.kernel.org
Date: Tue, 16 Aug 2011 13:54:09 +0200
Message-ID: <20110816115409.1810393.11784.stgit@localhost.localdomain>
In-Reply-To: <20110816115404.1810393.47239.stgit@localhost.localdomain>
References: <20110816115404.1810393.47239.stgit@localhost.localdomain>
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


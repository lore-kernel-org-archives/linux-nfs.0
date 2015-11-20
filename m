Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55897 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760374AbbKTOyw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 09:54:52 -0500
Subject: [PATCH 02/12] statx: Provide IOC flags for Windows fs attributes
From: David Howells <dhowells@redhat.com>
To: arnd@arndb.de
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Date: Fri, 20 Nov 2015 14:54:47 +0000
Message-ID: <20151120145447.18930.5308.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide IOC flags for Windows fs attributes so that they can be retrieved (or
even altered) using the FS_IOC_[GS]ETFLAGS ioctl and read using statx().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/uapi/linux/fs.h |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index 9b964a5920af..a195287b8744 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -197,10 +197,13 @@ struct inodes_stat_t {
 #define FS_EXTENT_FL			0x00080000 /* Extents */
 #define FS_DIRECTIO_FL			0x00100000 /* Use direct i/o */
 #define FS_NOCOW_FL			0x00800000 /* Do not cow file */
+#define FS_HIDDEN_FL			0x10000000 /* Windows hidden file attribute */
+#define FS_SYSTEM_FL			0x20000000 /* Windows system file attribute */
+#define FS_ARCHIVE_FL			0x40000000 /* Windows archive file attribute */
 #define FS_RESERVED_FL			0x80000000 /* reserved for ext2 lib */
 
-#define FS_FL_USER_VISIBLE		0x0003DFFF /* User visible flags */
-#define FS_FL_USER_MODIFIABLE		0x000380FF /* User modifiable flags */
+#define FS_FL_USER_VISIBLE		0x7003DFFF /* User visible flags */
+#define FS_FL_USER_MODIFIABLE		0x700380FF /* User modifiable flags */
 
 
 #define SYNC_FILE_RANGE_WAIT_BEFORE	1


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24865 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753677Ab3KLRg0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 12:36:26 -0500
Subject: [PATCH 1/3] statxat: Provide IOC flags for Windows fs attributes
To: viro@ZenIV.linux.org.uk
From: David Howells <dhowells@redhat.com>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        libc-alpha@sourceware.org, linux-api@vger.kernel.org,
        andreas.gruenbacher@gmail.com, samba-technical@lists.samba.org,
        linux-fsdevel@vger.kernel.org
Date: Tue, 12 Nov 2013 17:35:26 +0000
Message-ID: <20131112173526.25813.85546.stgit@warthog.procyon.org.uk>
In-Reply-To: <20131112173518.25813.67568.stgit@warthog.procyon.org.uk>
References: <20131112173518.25813.67568.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide IOC flags for Windows fs attributes so that they can be retrieved (or
even altered) using the FS_IOC_[GS]ETFLAGS ioctl and read using statxat().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/uapi/linux/fs.h |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index 6c28b61bb690..8b966f48dd41 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -191,10 +191,13 @@ struct inodes_stat_t {
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


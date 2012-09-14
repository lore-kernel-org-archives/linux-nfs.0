Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:51248 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756123Ab2INVXR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Sep 2012 17:23:17 -0400
Received: by ghbg15 with SMTP id g15so1131724ghb.19
        for <linux-nfs@vger.kernel.org>; Fri, 14 Sep 2012 14:23:16 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/10] NFS: nfs_parsed_mount_options can use unsigned int
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 14 Sep 2012 17:23:14 -0400
Message-ID: <20120914212313.1635.16943.stgit@degas.1015granger.net>
In-Reply-To: <20120914211053.1635.74063.stgit@degas.1015granger.net>
References: <20120914211053.1635.74063.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fs/nfs/super.c: In function ‘nfs_compare_remount_data’:
fs/nfs/super.c:2042:18: warning: comparison between signed and
    unsigned integer expressions [-Wsign-compare]
fs/nfs/super.c:2043:18: warning: comparison between signed and
    unsigned integer expressions [-Wsign-compare]
fs/nfs/super.c:2044:20: warning: comparison between signed and
    unsigned integer expressions [-Wsign-compare]
fs/nfs/super.c:2046:21: warning: comparison between signed and
    unsigned integer expressions [-Wsign-compare]
fs/nfs/super.c:2047:21: warning: comparison between signed and
    unsigned integer expressions [-Wsign-compare]
fs/nfs/super.c:2048:21: warning: comparison between signed and
    unsigned integer expressions [-Wsign-compare]
fs/nfs/super.c:2049:21: warning: comparison between signed and
    unsigned integer expressions [-Wsign-compare]
fs/nfs/super.c:2050:18: warning: comparison between signed and
    unsigned integer expressions [-Wsign-compare]

Seen with gcc (GCC) 4.6.3 20120306 (Red Hat 4.6.3-2).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 31fdb03..89560be 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -101,11 +101,11 @@ struct nfs_client_initdata {
  */
 struct nfs_parsed_mount_data {
 	int			flags;
-	int			rsize, wsize;
-	int			timeo, retrans;
-	int			acregmin, acregmax,
+	unsigned int		rsize, wsize;
+	unsigned int		timeo, retrans;
+	unsigned int		acregmin, acregmax,
 				acdirmin, acdirmax;
-	int			namlen;
+	unsigned int		namlen;
 	unsigned int		options;
 	unsigned int		bsize;
 	unsigned int		auth_flavor_len;


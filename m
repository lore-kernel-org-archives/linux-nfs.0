Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61699 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753286Ab0BVOJR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2010 09:09:17 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] Remove EXPERIMENTAL from NFS_FSCACHE
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-cachefs@redhat.com,
        Christian Kujau <lists@nerdbynature.de>,
        David Howells <dhowells@redhat.com>
Date: Mon, 22 Feb 2010 14:09:05 +0000
Message-ID: <20100222140905.21284.81120.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Christian Kujau <lists@nerdbynature.de>

There's currently an open Ubuntu bug[0], with the intent to compile NFS_FSCACHE
(and possibly AFS_FSCACHE, 9P_FSCACHE) into the standard Ubuntu kernel.
However, since *_FSCACHE still depends on EXPERIMENTAL, this won't happen.

As Arjan van de Ven pointed out[1], the EXPERIMENTAL flag doesn't mean that
much any more, I propose the following patch to fs/nfs/Kconfig.  I'd do the
same for fs/9p/Kconfig and fs/afs/Kconfig, but as I did not test 9p or AFS, I
feel it would not be appropriate for me to remove the flag.

[0] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/440522/comments/5
[1] http://lkml.org/lkml/2010/1/23/145

Signed-off-by: Christian Kujau <lists@nerdbynature.de>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/Kconfig |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 59e5673..a43d07e 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -95,8 +95,7 @@ config ROOT_NFS
 	  Most people say N here.
 
 config NFS_FSCACHE
-	bool "Provide NFS client caching support (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
+	bool "Provide NFS client caching support"
 	depends on NFS_FS=m && FSCACHE || NFS_FS=y && FSCACHE=y
 	help
 	  Say Y here if you want NFS data to be cached locally on disc through


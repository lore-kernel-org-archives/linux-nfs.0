From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 3/5] s390: remove unused nfsd #includes
Date: Tue, 24 Nov 2009 20:02:00 +0200
Message-ID: <4B0C1F98.4000204__22821.8123237186$1259086709$gmane$org@panasas.com>
References: <4B0C1EB7.50508@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-parisc <linux-parisc@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>,
	linux-s
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:33713 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932245AbZKXSQg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2009 13:16:36 -0500
In-Reply-To: <4B0C1EB7.50508@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Some unused includes removed.

This patch is in an effort to cleanup nfsd headers and move
private definitions to source directory.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 arch/s390/kernel/compat_linux.c |    6 ------
 arch/s390/kernel/compat_linux.h |    4 ----
 2 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 0debcec..29a2f34 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -31,14 +31,8 @@
 #include <linux/shm.h>
 #include <linux/slab.h>
 #include <linux/uio.h>
-#include <linux/nfs_fs.h>
 #include <linux/quota.h>
 #include <linux/module.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
-#include <linux/nfsd/xdr.h>
-#include <linux/nfsd/syscall.h>
 #include <linux/poll.h>
 #include <linux/personality.h>
 #include <linux/stat.h>
diff --git a/arch/s390/kernel/compat_linux.h b/arch/s390/kernel/compat_linux.h
index c07f9ca..81d6ee8 100644
--- a/arch/s390/kernel/compat_linux.h
+++ b/arch/s390/kernel/compat_linux.h
@@ -4,10 +4,6 @@
 #include <linux/compat.h>
 #include <linux/socket.h>
 #include <linux/syscalls.h>
-#include <linux/nfs_fs.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/export.h>
 
 /* Macro that masks the high order bit of an 32 bit pointer and converts it*/
 /*       to a 64 bit pointer */
-- 
1.6.5.2



From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 2/5] sparc: remove unused nfsd #includes
Date: Tue, 24 Nov 2009 20:01:00 +0200
Message-ID: <4B0C1F5C.9090903@panasas.com>
References: <4B0C1EB7.50508@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-parisc <linux-parisc@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>,
	linux-s
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:4489 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933739AbZKXSBW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2009 13:01:22 -0500
In-Reply-To: <4B0C1EB7.50508@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Some unused includes removed.

In an effort to cleanup nfsd headers and move private
definitions to source directory.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 arch/sparc/kernel/sys_sparc32.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/arch/sparc/kernel/sys_sparc32.c b/arch/sparc/kernel/sys_sparc32.c
index 04e28b2..0a68fdf 100644
--- a/arch/sparc/kernel/sys_sparc32.c
+++ b/arch/sparc/kernel/sys_sparc32.c
@@ -26,11 +26,6 @@
 #include <linux/nfs_fs.h>
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
-- 
1.6.5.2



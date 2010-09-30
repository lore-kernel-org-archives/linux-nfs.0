Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8255 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751724Ab0I3UE5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 16:04:57 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o8UK4vgF031915
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 30 Sep 2010 16:04:57 -0400
Received: from badhat.bos.devel.redhat.com (badhat.boston.devel.redhat.com [10.16.60.49])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o8UK4vIB004904
	for <linux-nfs@vger.kernel.org>; Thu, 30 Sep 2010 16:04:57 -0400
Message-ID: <4CA4ED68.3090806@RedHat.com>
Date: Thu, 30 Sep 2010 16:04:56 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] pnfs:  compile error in blocklayout code
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I needed to make the following change to get the
block layout code to compile in a Fedora build 
environment.

Signed-off-by: Steve Dickson <steved@redhat.com>

diff -up linux-2.6.35.x86_64/fs/nfs/blocklayout/blocklayout.h.orig linux-2.6.35.x86_64/fs/nfs/blocklayout/blocklayout.h
--- linux-2.6.35.x86_64/fs/nfs/blocklayout/blocklayout.h.orig	2010-09-30 14:35:49.800480934 -0400
+++ linux-2.6.35.x86_64/fs/nfs/blocklayout/blocklayout.h	2010-09-30 15:09:14.118105750 -0400
@@ -34,7 +34,7 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/dm-ioctl.h> /* Needed for struct dm_ioctl*/
-#include <../pnfs.h>
+#include "../pnfs.h"
 
 #define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> 9)
 

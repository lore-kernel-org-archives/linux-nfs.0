Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52285 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756253Ab1FGRet (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:34:49 -0400
Date: Tue, 7 Jun 2011 13:34:47 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 75/88] SQUASHME: pnfsblock: compile error in blocklayout code
Message-ID: <0d5949b60e74efa9aa303f9112d7c6a259a35574.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Steve Dickson <SteveD@redhat.com>

I needed to make the following change to get the
block layout code to compile in a Fedora build
environment.

Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 7db7768..9e7bd62 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -34,7 +34,7 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/dm-ioctl.h> /* Needed for struct dm_ioctl*/
-#include <../pnfs.h>
+#include "../pnfs.h"
 
 #define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> 9)
 
-- 
1.7.4.1


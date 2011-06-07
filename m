Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53118 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab1FGR1o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:27:44 -0400
Date: Tue, 7 Jun 2011 13:27:41 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 16/88] pnfsblock: select BLK_DEV_DM when PNFS_BLOCK is
 configured
Message-ID: <83176d715bf7009b66f388ca6ddac98193e2ecf0.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Also, select MD

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Kconfig |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index d6bfd87..bccd415 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -108,6 +108,8 @@ config PNFS_PANLAYOUT
 config PNFS_BLOCK
 	tristate "Provide a pNFS block client (EXPERIMENTAL)"
 	depends on NFS_FS && PNFS
+	select MD
+	select BLK_DEV_DM
 	help
 	  Say M or y here if you want your pNfs client to support the block protocol
 
-- 
1.7.4.1


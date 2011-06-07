Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:50875 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932106Ab1FGRay (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:30:54 -0400
Date: Tue, 7 Jun 2011 13:30:52 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 41/88] SQUASHME: pnfs-block: remove of CONFIG_PNFS fallout
Message-ID: <9de022dfa83437eb114dfa0975978c98cc27ebc8.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Boaz Harrosh <bharrosh@panasas.com>

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[depend on NFS_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index bccd415..c8bd06c 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -107,7 +107,7 @@ config PNFS_PANLAYOUT
 
 config PNFS_BLOCK
 	tristate "Provide a pNFS block client (EXPERIMENTAL)"
-	depends on NFS_FS && PNFS
+	depends on NFS_FS && NFS_V4_1
 	select MD
 	select BLK_DEV_DM
 	help
-- 
1.7.4.1


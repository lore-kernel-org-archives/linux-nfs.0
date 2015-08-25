Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7955 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000AbbHYDWe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2015 23:22:34 -0400
Date: Tue, 25 Aug 2015 11:19:25 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: kbuild-all@01.org, linux-nfs@vger.kernel.org
Subject: [PATCH nfs] NFSv4.1/flexfile: ff_layout_remove_mirror can be static
Message-ID: <20150825031925.GA124235@xian>
References: <201508251105.4jGlfxvH%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201508251105.4jGlfxvH%fengguang.wu@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 flexfilelayout.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 2103527..22d1791 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -183,7 +183,7 @@ ff_layout_add_mirror(struct pnfs_layout_hdr *lo,
 	return mirror;
 }
 
-void
+static void
 ff_layout_remove_mirror(struct nfs4_ff_layout_mirror *mirror)
 {
 	struct inode *inode;

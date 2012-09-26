Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:22950 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824Ab2IZBip (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Sep 2012 21:38:45 -0400
Date: Wed, 26 Sep 2012 09:38:39 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Yuanhan Liu <yuanhan.liu@intel.com>, kernel-janitors@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [nfs:devel 17/39] fs/nfs/pnfs.c:1043:20: warning: unused variable
 'nfsi'
Message-ID: <20120926013839.GD8522@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

FYI, there are new compile warnings show up in

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel
head:   f743c735b817547b590d36a6e275235c7beb8600
commit: a9c310af706112f44c15cf5172e81ba3ee755cab [17/39] NFSv4.1: Add helpers for setting/reading the I/O fail bit

All warnings:

fs/nfs/pnfs.c: In function 'pnfs_update_layout':
fs/nfs/pnfs.c:1043:20: warning: unused variable 'nfsi' [-Wunused-variable]

vim +1043 fs/nfs/pnfs.c
  1027	 * The appropriate layout segment is referenced and returned to the caller.
  1028	 */
  1029	struct pnfs_layout_segment *
  1030	pnfs_update_layout(struct inode *ino,
  1031			   struct nfs_open_context *ctx,
  1032			   loff_t pos,
  1033			   u64 count,
  1034			   enum pnfs_iomode iomode,
  1035			   gfp_t gfp_flags)
  1036	{
  1037		struct pnfs_layout_range arg = {
  1038			.iomode = iomode,
  1039			.offset = pos,
  1040			.length = count,
  1041		};
  1042		unsigned pg_offset;
> 1043		struct nfs_inode *nfsi = NFS_I(ino);
  1044		struct nfs_server *server = NFS_SERVER(ino);
  1045		struct nfs_client *clp = server->nfs_client;
  1046		struct pnfs_layout_hdr *lo;
  1047		struct pnfs_layout_segment *lseg = NULL;
  1048		bool first = false;
  1049	
  1050		if (!pnfs_enabled_sb(NFS_SERVER(ino)))
  1051			return NULL;

---
0-DAY kernel build testing backend         Open Source Technology Centre
Fengguang Wu, Yuanhan Liu                              Intel Corporation

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:15890 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752818Ab2ISXf4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Sep 2012 19:35:56 -0400
Date: Thu, 20 Sep 2012 07:35:51 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: kernel-janitors@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [nfs:testing 13/18] nfs4proc.c:(.text+0x157ca4): undefined reference
 to `pnfs_put_layout_hdr'
Message-ID: <20120919233551.GE5607@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

FYI, kernel build failed on

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
head:   c5d13e10816a6c758d31f291c86ad2ef16c8620a
commit: 588b33511b85dd532ef5630ba6b6e3982b8e170d [13/18] NFSv4.1: Cleanup; add "pnfs_" prefix to get_layout_hdr() and put_layout_hdr()
config: i386-allyesconfig

All related error/warning messages:

fs/built-in.o: In function `nfs4_layoutreturn_release':
nfs4proc.c:(.text+0x157ca4): undefined reference to `pnfs_put_layout_hdr'
fs/built-in.o: In function `do_callback_layoutrecall':
callback_proc.c:(.text+0x16cd17): undefined reference to `pnfs_put_layout_hdr'
callback_proc.c:(.text+0x16cde5): undefined reference to `pnfs_get_layout_hdr'
callback_proc.c:(.text+0x16cea1): undefined reference to `pnfs_put_layout_hdr'
callback_proc.c:(.text+0x16cef8): undefined reference to `pnfs_get_layout_hdr'
fs/built-in.o: In function `pnfs_update_layout':
(.text+0x16fa6f): undefined reference to `pnfs_get_layout_hdr'
fs/built-in.o: In function `pnfs_update_layout':
(.text+0x16fc34): undefined reference to `pnfs_put_layout_hdr'
fs/built-in.o: In function `pnfs_free_lseg_list':
(.text+0x1701ca): undefined reference to `pnfs_put_layout_hdr'
fs/built-in.o: In function `_pnfs_return_layout':
(.text+0x170284): undefined reference to `pnfs_get_layout_hdr'
fs/built-in.o: In function `_pnfs_return_layout':
(.text+0x1702a9): undefined reference to `pnfs_put_layout_hdr'
fs/built-in.o: In function `_pnfs_return_layout':
(.text+0x170328): undefined reference to `pnfs_put_layout_hdr'
fs/built-in.o: In function `pnfs_roc':
(.text+0x170d96): undefined reference to `pnfs_get_layout_hdr'
fs/built-in.o: In function `pnfs_layout_process':
(.text+0x171106): undefined reference to `pnfs_get_layout_hdr'

---
0-DAY kernel build testing backend         Open Source Technology Centre
Fengguang Wu, Yuanhan Liu                              Intel Corporation

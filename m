Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga14.intel.com ([143.182.124.37]:26912 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761979Ab2KAWK0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Nov 2012 18:10:26 -0400
Date: Fri, 02 Nov 2012 06:09:49 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [nfs:devel 56/57] ERROR: "nfs4_set_task_privileged" undefined!
Message-ID: <5092f32d.GyLHMcsJgmCj4qY2%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel
head:   4edd254f1e17d3a49f5a1cf159ddf5e586a41fa9
commit: 86d750f84f3c041ff79ea118a95613b3fc346551 [56/57] NFSv4.1: Remove the 'FIFO' behaviour for nfs41_setup_sequence
config: make ARCH=x86_64 allmodconfig

All error/warnings:

ERROR: "nfs4_set_task_privileged" undefined!

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation

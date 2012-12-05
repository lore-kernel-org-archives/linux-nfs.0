Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga14.intel.com ([143.182.124.37]:10386 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660Ab2LEIeJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Dec 2012 03:34:09 -0500
Date: Wed, 05 Dec 2012 16:32:39 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [nfs:testing 53/84] fs/nfs/callback_proc.c:579:8: error: 'struct
 nfs4_slot_table' has no member named 'target_max_slots'
Message-ID: <50bf06a7.E74VS7UWGC6h0lke%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
head:   6a7055a331aaff115b0b81f62ef5767511dcfd72
commit: ab388b1b587abb5001f30f7b0ec58e4eab082139 [53/84] NFSv4.1: Ensure that the client tracks the server target_highest_slotid
config: make ARCH=x86_64 allmodconfig

Note: the nfs/testing HEAD 6a7055a builds fine.
      It only hurts bisectibility.

All error/warnings:

fs/nfs/callback_proc.c: In function 'nfs4_callback_recallslot':
fs/nfs/callback_proc.c:579:8: error: 'struct nfs4_slot_table' has no member named 'target_max_slots'

vim +579 fs/nfs/callback_proc.c

c36fca52 Andy Adamson 2011-01-06  573  		goto out;
bae0ac0e Andy Adamson 2010-01-21  574  
bae0ac0e Andy Adamson 2010-01-21  575  	status = htonl(NFS4_OK);
bae0ac0e Andy Adamson 2010-01-21  576  	if (args->crsa_target_max_slots == fc_tbl->max_slots)
c36fca52 Andy Adamson 2011-01-06  577  		goto out;
b9efa1b2 Andy Adamson 2010-01-20  578  
b9efa1b2 Andy Adamson 2010-01-20 @579  	fc_tbl->target_max_slots = args->crsa_target_max_slots;
c36fca52 Andy Adamson 2011-01-06  580  	nfs41_handle_recall_slot(cps->clp);
b9efa1b2 Andy Adamson 2010-01-20  581  out:
b9efa1b2 Andy Adamson 2010-01-20  582  	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation

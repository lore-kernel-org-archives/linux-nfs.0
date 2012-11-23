Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:51063 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751334Ab2KWFtL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Nov 2012 00:49:11 -0500
Date: Fri, 23 Nov 2012 13:48:15 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [nfs:devel 73/73] fs/nfs/nfs4proc.c:743:31: error: expected ')'
 before ';' token
Message-ID: <50af0e1f.4y40S77mWeEZCRr9%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel
head:   29c32c56a420896f372c6efd3b6588b41b735ae8
commit: 29c32c56a420896f372c6efd3b6588b41b735ae8 [73/73] NFSv4.1: If slot allocation fails due to OOM, retry more quickly
config: make ARCH=x86_64 allmodconfig

All error/warnings:

fs/nfs/nfs4proc.c: In function 'nfs41_setup_sequence':
fs/nfs/nfs4proc.c:743:31: error: expected ')' before ';' token
fs/nfs/nfs4proc.c:747:2: error: expected expression before '}' token

vim +743 fs/nfs/nfs4proc.c

cc9673a8 Trond Myklebust 2012-11-01  737  		goto out_sleep;
b069d94a Andy Adamson    2009-04-01  738  	}
b069d94a Andy Adamson    2009-04-01  739  
779b9e08 Trond Myklebust 2012-11-16  740  	slot = nfs4_alloc_slot(tbl);
29c32c56 Trond Myklebust 2012-11-22  741  	if (IS_ERR(slot)) {
29c32c56 Trond Myklebust 2012-11-22  742  		/* If out of memory, try again in 1/4 second */
29c32c56 Trond Myklebust 2012-11-22 @743  		if (slot == ERR_PTR(-ENOMEM);
29c32c56 Trond Myklebust 2012-11-22  744  			task->tk_timeout = HZ >> 2;
fbcd4abc Andy Adamson    2009-04-01  745  		dprintk("<-- %s: no free slots\n", __func__);
cc9673a8 Trond Myklebust 2012-11-01  746  		goto out_sleep;
fbcd4abc Andy Adamson    2009-04-01 @747  	}
fbcd4abc Andy Adamson    2009-04-01  748  	spin_unlock(&tbl->slot_tbl_lock);
fbcd4abc Andy Adamson    2009-04-01  749  
b23acb7c Trond Myklebust 2012-11-16  750  	args->sa_slot = slot;

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation

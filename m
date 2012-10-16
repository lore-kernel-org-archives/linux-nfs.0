Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga02.intel.com ([134.134.136.20]:53095 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755135Ab2JPRYJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 13:24:09 -0400
Date: Wed, 17 Oct 2012 01:24:05 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: kernel-janitors@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [nfs:testing 6/19] fs/nfs/callback.c:239:3: error: 'ret' undeclared
Message-ID: <20121016172405.GC11813@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

FYI, kernel build failed on

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
head:   7d84fbe58c098cb9200e1d9180ae50d49e54e4e2
commit: 8c47a6a6ce14a7baf1c5d6a169523cb083f9aaa9 [6/19] NFSv4: Remove an unused variable from nfs_callback_start_svc
config: x86_64-allyesconfig # make ARCH=x86_64 

All error/warnings:

fs/nfs/callback.c: In function 'nfs_callback_start_svc':
fs/nfs/callback.c:239:3: error: 'ret' undeclared (first use in this function)
fs/nfs/callback.c:239:3: note: each undeclared identifier is reported only once for each function it appears in

vim +239 fs/nfs/callback.c

8e246144 Stanislav Kinsbursky 2012-08-20  233  
8e246144 Stanislav Kinsbursky 2012-08-20  234  	sprintf(svc_name, "nfsv4.%u-svc", minorversion);
8e246144 Stanislav Kinsbursky 2012-08-20  235  	cb_info->serv = serv;
8e246144 Stanislav Kinsbursky 2012-08-20  236  	cb_info->rqst = rqstp;
8e246144 Stanislav Kinsbursky 2012-08-20  237  	cb_info->task = kthread_run(callback_svc, cb_info->rqst, svc_name);
8e246144 Stanislav Kinsbursky 2012-08-20  238  	if (IS_ERR(cb_info->task)) {
8e246144 Stanislav Kinsbursky 2012-08-20 @239  		ret = PTR_ERR(cb_info->task);
8e246144 Stanislav Kinsbursky 2012-08-20  240  		svc_exit_thread(cb_info->rqst);
8e246144 Stanislav Kinsbursky 2012-08-20  241  		cb_info->rqst = NULL;
8e246144 Stanislav Kinsbursky 2012-08-20  242  		cb_info->task = NULL;

The code at line 239 was first introduced by commit:
8e24614 NFS: callback service start function introduced


---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation

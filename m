Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:50640 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897Ab2JBFfV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 01:35:21 -0400
Date: Tue, 2 Oct 2012 13:13:51 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: kernel-janitors@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [nfs:nfs-for-next 54/83] fs/nfs/super.c:2638:16: sparse: symbol
 'nfs_callback_tcpport' was not declared. Should it be static?
Message-ID: <20121002051351.GB18119@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Stanislav,

FYI, there are new sparse warnings show up in

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git nfs-for-next
head:   2afdfa5a846246de50e1881f71ba5c0aac0b415f
commit: bbe0a3aa4e227c8aae02a484ce1c0b655cd19055 [54/83] NFS: make nfs_callback_tcpport per network context

? fs/nfs/super.c:2638:16: sparse: symbol 'nfs_callback_tcpport' was not declared. Should it be static?

Shall we also remove the two related lines below?

vim +2638 fs/nfs/super.c

fac1e8e4 (Bryan Schumaker   2012-07-30  2633) /*
fac1e8e4 (Bryan Schumaker   2012-07-30  2634)  * NFS v4 module parameters need to stay in the
fac1e8e4 (Bryan Schumaker   2012-07-30  2635)  * NFS client for backwards compatibility
fac1e8e4 (Bryan Schumaker   2012-07-30  2636)  */
fac1e8e4 (Bryan Schumaker   2012-07-30  2637) unsigned int nfs_callback_set_tcpport;
fac1e8e4 (Bryan Schumaker   2012-07-30 @2638) unsigned short nfs_callback_tcpport;
fac1e8e4 (Bryan Schumaker   2012-07-30  2639) /* Default cache timeout is 10 minutes */
fac1e8e4 (Bryan Schumaker   2012-07-30  2640) unsigned int nfs_idmap_cache_timeout = 600;
fac1e8e4 (Bryan Schumaker   2012-07-30  2641) /* Turn off NFSv4 uid/gid mapping when using AUTH_SYS */
fac1e8e4 (Bryan Schumaker   2012-07-30  2642) bool nfs4_disable_idmapping = true;
fac1e8e4 (Bryan Schumaker   2012-07-30  2643) unsigned short max_session_slots = NFS4_DEF_SLOT_TABLE_SIZE;
fac1e8e4 (Bryan Schumaker   2012-07-30  2644) unsigned short send_implementation_id = 1;
fac1e8e4 (Bryan Schumaker   2012-07-30  2645) 
89d77c8f (Bryan Schumaker   2012-07-30  2646) EXPORT_SYMBOL_GPL(nfs_callback_set_tcpport);
89d77c8f (Bryan Schumaker   2012-07-30 @2647) EXPORT_SYMBOL_GPL(nfs_callback_tcpport);
89d77c8f (Bryan Schumaker   2012-07-30  2648) EXPORT_SYMBOL_GPL(nfs_idmap_cache_timeout);
89d77c8f (Bryan Schumaker   2012-07-30  2649) EXPORT_SYMBOL_GPL(nfs4_disable_idmapping);
89d77c8f (Bryan Schumaker   2012-07-30  2650) EXPORT_SYMBOL_GPL(max_session_slots);
89d77c8f (Bryan Schumaker   2012-07-30  2651) EXPORT_SYMBOL_GPL(send_implementation_id);
89d77c8f (Bryan Schumaker   2012-07-30  2652) 
fac1e8e4 (Bryan Schumaker   2012-07-30  2653) #define NFS_CALLBACK_MAXPORTNR (65535U)
fac1e8e4 (Bryan Schumaker   2012-07-30  2654) 

---
0-DAY kernel build testing backend         Open Source Technology Centre
Fengguang Wu, Yuanhan Liu                              Intel Corporation

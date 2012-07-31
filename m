Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:63657 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752029Ab2GaDPN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jul 2012 23:15:13 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Fengguang Wu <fengguang.wu@intel.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [nfs:devel 46/51] fs/nfs/write.c:1592:5: error: redefinition of
 'nfs_commit_inode'
Date: Tue, 31 Jul 2012 03:14:56 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA934BE82@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120731024328.GA10480@localhost>
In-Reply-To: <20120731024328.GA10480@localhost>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bryan,

Why did you switch to using IS_ENABLED in the first place, and why wasn't that put in a separate patch?



> -----Original Message-----
> From: Fengguang Wu [mailto:fengguang.wu@intel.com]
> Sent: Monday, July 30, 2012 10:43 PM
> To: Schumaker, Bryan
> Cc: kernel-janitors@vger.kernel.org; Myklebust, Trond; linux-
> nfs@vger.kernel.org
> Subject: [nfs:devel 46/51] fs/nfs/write.c:1592:5: error: redefinition of
> 'nfs_commit_inode'
> 
> Hi Bryan,
> 
> Kernel build failed on
> 
> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel
> head:   5c13c9e1c15ee2ca9ab2b953224001af53d9be09
> commit: 1c606fb74c758beafd98cbad9a9133eadeec2371 [46/51] NFS: Convert
> v3 into a module
> config: blackfin-BF533-EZKIT_defconfig (attached as .config)
> 
> All related error/warning messages:
> 
> fs/nfs/write.c:1592:5: error: redefinition of 'nfs_commit_inode'
> In file included from fs/nfs/write.c:19:0:
> include/linux/nfs_fs.h:547:1: note: previous definition of 'nfs_commit_inode'
> was here
> 
> vim +1592 fs/nfs/write.c
>   1589		return status;
>   1590	}
>   1591
> > 1592	int nfs_commit_inode(struct inode *inode, int how)
>   1593	{
>   1594		LIST_HEAD(head);
>   1595		struct nfs_commit_info cinfo;
> 
> ---
> 0-DAY kernel build testing backend         Open Source Technology Centre
> Fengguang Wu <wfg@linux.intel.com>                     Intel Corporation

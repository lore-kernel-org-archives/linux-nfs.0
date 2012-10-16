Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42554 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754981Ab2JPR1K convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Oct 2012 13:27:10 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Fengguang Wu <fengguang.wu@intel.com>
CC: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [nfs:testing 6/19] fs/nfs/callback.c:239:3: error: 'ret'
 undeclared
Date: Tue, 16 Oct 2012 17:27:08 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA90925FC81@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121016172405.GC11813@localhost>
In-Reply-To: <20121016172405.GC11813@localhost>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Fengguang Wu [mailto:fengguang.wu@intel.com]
> Sent: Tuesday, October 16, 2012 1:24 PM
> To: Myklebust, Trond
> Cc: kernel-janitors@vger.kernel.org; linux-nfs@vger.kernel.org
> Subject: [nfs:testing 6/19] fs/nfs/callback.c:239:3: error: 'ret' undeclared
> 
> Hi Trond,
> 
> FYI, kernel build failed on
> 
> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
> head:   7d84fbe58c098cb9200e1d9180ae50d49e54e4e2
> commit: 8c47a6a6ce14a7baf1c5d6a169523cb083f9aaa9 [6/19] NFSv4: Remove
> an unused variable from nfs_callback_start_svc
> config: x86_64-allyesconfig # make ARCH=x86_64
> 
> All error/warnings:
> 
> fs/nfs/callback.c: In function 'nfs_callback_start_svc':
> fs/nfs/callback.c:239:3: error: 'ret' undeclared (first use in this function)
> fs/nfs/callback.c:239:3: note: each undeclared identifier is reported only once
> for each function it appears in
> 

Hi Fengguang,

Yes. This issue is already fixed in the repository. Sorry for having pushed it out too quickly...

Cheers
  Trond

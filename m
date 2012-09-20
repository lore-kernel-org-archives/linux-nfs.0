Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:25705 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751Ab2ITMR3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Sep 2012 08:17:29 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Fengguang Wu <fengguang.wu@intel.com>
CC: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [nfs:testing 13/18] nfs4proc.c:(.text+0x157ca4): undefined
 reference to `pnfs_put_layout_hdr'
Date: Thu, 20 Sep 2012 12:17:27 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908FDA695@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120919233551.GE5607@localhost>
In-Reply-To: <20120919233551.GE5607@localhost>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Fengguang Wu [mailto:fengguang.wu@intel.com]
> Sent: Wednesday, September 19, 2012 7:36 PM
> To: Myklebust, Trond
> Cc: kernel-janitors@vger.kernel.org; linux-nfs@vger.kernel.org
> Subject: [nfs:testing 13/18] nfs4proc.c:(.text+0x157ca4): undefined
> reference to `pnfs_put_layout_hdr'
> 
> Hi Trond,
> 
> FYI, kernel build failed on
> 
> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
> head:   c5d13e10816a6c758d31f291c86ad2ef16c8620a
> commit: 588b33511b85dd532ef5630ba6b6e3982b8e170d [13/18] NFSv4.1:
> Cleanup; add "pnfs_" prefix to get_layout_hdr() and put_layout_hdr()
> config: i386-allyesconfig
> 

Thank you Fengguang!  I've fixed this up in today's tree.

Cheers
   Trond

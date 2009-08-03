From: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Subject: Re: nfs: __setup_str_nfs_root_setup causes a section type conflict
Date: Mon, 3 Aug 2009 21:21:08 +0200
Message-ID: <200908032121.10635.elendil@planet.nl>
References: <200907311446.33486.elendil@planet.nl> <200908020010.30459.elendil@planet.nl> <1249323782.18161.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	parisc-linux-T/XaZq8tFt7U4lJK3ijXoz+iFHGzDt/a@public.gmane.org, Helge Deller <deller@gmx.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from Cpsmtpm-eml108.kpnxchange.com ([195.121.3.12]:58255 "EHLO
	CPSMTPM-EML108.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752665AbZHCTVL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Aug 2009 15:21:11 -0400
In-Reply-To: <1249323782.18161.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 03 August 2009, Trond Myklebust wrote:
> > > /home/fjp/projects/kernel/linux-2.6/fs/nfs/nfsroot.c:403:
> > >     error: __setup_str_nfs_root_setup causes a section type
> > > conflict
>
> If you do a 'make fs/nfs/nfsroot.i', and then look at the resulting
> file fs/nfs/nfsroot.i, what does the line that defines
> '__setup_str_nfs_root_setup' look like?

$ grep __setup_str_nfs_root_setup fs/nfs/nfsroot.i

static const char __setup_str_nfs_root_setup[] __attribute__ 
((__section__(".init.rodata"))) __attribute__((aligned(1))) = "nfsroot="; 
static struct obs_kernel_param __setup_nfs_root_setup 
__attribute__((__used__)) __attribute__ ((__section__(".init.setup"))) 
__attribute__((aligned((sizeof(long))))) = { __setup_str_nfs_root_setup, 
nfs_root_setup, 0 };

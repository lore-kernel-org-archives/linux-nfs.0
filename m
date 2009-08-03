From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs: __setup_str_nfs_root_setup causes a section type conflict
Date: Mon, 03 Aug 2009 14:23:02 -0400
Message-ID: <1249323782.18161.2.camel@heimdal.trondhjem.org>
References: <200907311446.33486.elendil@planet.nl>
	 <200908020010.30459.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	parisc-linux-T/XaZq8tFt7U4lJK3ijXoz+iFHGzDt/a@public.gmane.org, Helge Deller <deller@gmx.de>
To: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:60443 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753695AbZHCSXH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Aug 2009 14:23:07 -0400
In-Reply-To: <200908020010.30459.elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-08-02 at 00:10 +0200, Frans Pop wrote:
> On Friday 31 July 2009, Frans Pop wrote:
> > While compiling v2.6.31-rc4-294-gf5886c7 for parisc (64-bits) I ran
> > into the following compilation error:
> >
> > /home/fjp/projects/kernel/linux-2.6/fs/nfs/nfsroot.c:403:
> >     error: __setup_str_nfs_root_setup causes a section type conflict
> > make[7]: *** [fs/nfs/nfsroot.o] Error 1
> 


If you do a 'make fs/nfs/nfsroot.i', and then look at the resulting file
fs/nfs/nfsroot.i, what does the line that defines
'__setup_str_nfs_root_setup' look like?

Cheers
  Trond


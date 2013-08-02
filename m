Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8244 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752966Ab3HBCdZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 22:33:25 -0400
Subject: Re: Trouble with kerberized NFS client after upgrading from
 nfs-utils 1.2.0 to 1.2.5
From: Simo Sorce <simo@redhat.com>
To: Rohit Mehta <rohitm@engr.uconn.edu>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <51FB0946.5020505@engr.uconn.edu>
References: <51FAC933.40508@engr.uconn.edu>
	 <1375391193.15733.213.camel@willson.li.ssimo.org>
	 <51FB0946.5020505@engr.uconn.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 01 Aug 2013 22:33:22 -0400
Message-ID: <1375410802.15733.216.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-08-01 at 21:20 -0400, Rohit Mehta wrote:
> Thanks Simo, it doesn't look like libtirpc was available in previous 
> (10.04) release of Ubuntu.
> root@c27-00:~# ldd /usr/sbin/

I assume this had ^^ rpc.gssd at the end and is just a copy&paste error.

>          linux-vdso.so.1 =>  (0x00007fffeedff000)
>          libgssglue.so.1 => /lib/libgssglue.so.1 (0x00007fb06778e000)
>          libkrb5.so.3 => /usr/lib/x86_64-linux-gnu/libkrb5.so.3 
> (0x00007fb0674c0000)
>          libcom_err.so.2 => /lib/x86_64-linux-gnu/libcom_err.so.2 
> (0x00007fb0672bb000)
>          libtirpc.so.1 => /lib/x86_64-linux-gnu/libtirpc.so.1 
> (0x00007fb067093000)
>          libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fb066cd4000)
>          libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fb066acf000)
>          libk5crypto.so.3 => /usr/lib/x86_64-linux-gnu/libk5crypto.so.3 
> (0x00007fb0668a7000)
>          libkrb5support.so.0 => 
> /usr/lib/x86_64-linux-gnu/libkrb5support.so.0 (0x00007fb06669f000)
>          libkeyutils.so.1 => /lib/x86_64-linux-gnu/libkeyutils.so.1 
> (0x00007fb06649a000)
>          libresolv.so.2 => /lib/x86_64-linux-gnu/libresolv.so.2 
> (0x00007fb06627e000)
>          libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 
> (0x00007fb066061000)
>          /lib64/ld-linux-x86-64.so.2 (0x00007fb0679b8000)
> root@c27-00:~# locate libtirpc.so
> /lib/x86_64-linux-gnu/libtirpc.so.1
> /lib/x86_64-linux-gnu/libtirpc.so.1.0.10
> root@c27-00:~# ldd /lib/x86_64-linux-gnu/libtirpc.so.1
>          linux-vdso.so.1 =>  (0x00007fff01dc1000)
>          libgssglue.so.1 => /lib/libgssglue.so.1 (0x00007fb701d54000)
>          libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 
> (0x00007fb701b37000)
>          libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fb701777000)
>          libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fb701573000)
>          /lib64/ld-linux-x86-64.so.2 (0x00007fb7021a6000)
> root@c27-00:~#

Both are built against libgssglue so at least they are consistent, and
that is not the source of the problem as I suspected.

More information on the actual error would help.

Simo.


> On 08/01/2013 05:06 PM, Simo Sorce wrote:
> >
> > Rohit
> > Was libtirpc also updated ?
> > There has beena  change recently where we eliminated the use of
> > libgssglue and you will get issues if both nfs-utils and libtirpc are
> > not compiled to use the same gssapi library.
> >
> > Please post ldd output on rpc.gssd and libtirpc.so to verify if this is
> > the issue.
> >
> > Simo.
> >
> 
> 


-- 
Simo Sorce * Red Hat, Inc * New York


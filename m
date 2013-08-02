Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ecs-ex10-cas2.engr.uconn.edu ([137.99.15.237]:53202 "EHLO
	mail.engr.uconn.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751484Ab3HBBUs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Aug 2013 21:20:48 -0400
Message-ID: <51FB0946.5020505@engr.uconn.edu>
Date: Thu, 1 Aug 2013 21:20:06 -0400
From: Rohit Mehta <rohitm@engr.uconn.edu>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: Trouble with kerberized NFS client after upgrading from nfs-utils
 1.2.0 to 1.2.5
References: <51FAC933.40508@engr.uconn.edu> <1375391193.15733.213.camel@willson.li.ssimo.org>
In-Reply-To: <1375391193.15733.213.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Simo, it doesn't look like libtirpc was available in previous 
(10.04) release of Ubuntu.
root@c27-00:~# ldd /usr/sbin/
         linux-vdso.so.1 =>  (0x00007fffeedff000)
         libgssglue.so.1 => /lib/libgssglue.so.1 (0x00007fb06778e000)
         libkrb5.so.3 => /usr/lib/x86_64-linux-gnu/libkrb5.so.3 
(0x00007fb0674c0000)
         libcom_err.so.2 => /lib/x86_64-linux-gnu/libcom_err.so.2 
(0x00007fb0672bb000)
         libtirpc.so.1 => /lib/x86_64-linux-gnu/libtirpc.so.1 
(0x00007fb067093000)
         libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fb066cd4000)
         libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fb066acf000)
         libk5crypto.so.3 => /usr/lib/x86_64-linux-gnu/libk5crypto.so.3 
(0x00007fb0668a7000)
         libkrb5support.so.0 => 
/usr/lib/x86_64-linux-gnu/libkrb5support.so.0 (0x00007fb06669f000)
         libkeyutils.so.1 => /lib/x86_64-linux-gnu/libkeyutils.so.1 
(0x00007fb06649a000)
         libresolv.so.2 => /lib/x86_64-linux-gnu/libresolv.so.2 
(0x00007fb06627e000)
         libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 
(0x00007fb066061000)
         /lib64/ld-linux-x86-64.so.2 (0x00007fb0679b8000)
root@c27-00:~# locate libtirpc.so
/lib/x86_64-linux-gnu/libtirpc.so.1
/lib/x86_64-linux-gnu/libtirpc.so.1.0.10
root@c27-00:~# ldd /lib/x86_64-linux-gnu/libtirpc.so.1
         linux-vdso.so.1 =>  (0x00007fff01dc1000)
         libgssglue.so.1 => /lib/libgssglue.so.1 (0x00007fb701d54000)
         libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 
(0x00007fb701b37000)
         libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fb701777000)
         libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fb701573000)
         /lib64/ld-linux-x86-64.so.2 (0x00007fb7021a6000)
root@c27-00:~#



On 08/01/2013 05:06 PM, Simo Sorce wrote:
>
> Rohit
> Was libtirpc also updated ?
> There has beena  change recently where we eliminated the use of
> libgssglue and you will get issues if both nfs-utils and libtirpc are
> not compiled to use the same gssapi library.
>
> Please post ldd output on rpc.gssd and libtirpc.so to verify if this is
> the issue.
>
> Simo.
>


-- 
Rohit Mehta
Computer Engineer
University of Connecticut
Engineering Computing Services
371 Fairfield Road Unit 2031
Storrs, CT 06269-2031


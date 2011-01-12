Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtpo13.poczta.onet.pl ([213.180.142.144]:42350 "EHLO
	smtpo13.poczta.onet.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722Ab1ALNvp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jan 2011 08:51:45 -0500
Received: from localhost.localdomain (unknown [83.238.22.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: sdrb@onet.eu)
	by smtp.poczta.onet.pl (Onet) with ESMTPSA id C78E320088B03
	for <linux-nfs@vger.kernel.org>; Wed, 12 Jan 2011 14:52:03 +0100 (CET)
Message-ID: <4D2DB1D8.8030606@onet.eu>
Date: Wed, 12 Jan 2011 14:51:20 +0100
From: sdrb <sdrb@onet.eu>
To: linux-nfs@vger.kernel.org
Subject: Re: Issue in nfs-utils 1.2.3
References: <4D2D910F.1080703@onet.eu>
In-Reply-To: <4D2D910F.1080703@onet.eu>
Content-Type: multipart/mixed;
 boundary="------------020308070404000209040409"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------020308070404000209040409
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 01/12/2011 12:31 PM, sdrb wrote:
> Hello,
>
>
> Recently I tried to upgrade nfs-utils to the newest nfs-utils 1.2.3.
> During tests I noticed that in some circumstances rpc.mountd
> crashes with segmentation fault.
> I'm testing it with 2.6.36 linux kernel.
>
>
> Configuration of nfs-server:
>
> server# cat /etc/exports
> /export *(rw)
> /tmp/nfs *(rw)
>
>
> The scenario how to reproduce the issue:
>
> server# rpc.mountd -F -d all
> server# showmount -a 127.0.0.1
> host# umount /mnt/nfs2 ; mount -t nfs server:/tmp/nfs /mnt/nfs2 -o
> nfsvers=3,nolock
> server# showmount -a 127.0.0.1
>
>
> and after spawning showmount for the second time I got two segmentation
> faults: at showmount and at rpc.mountd.
>
> Here is output from rpc.mountd:
> rpc.mountd: Received DUMP request from 127.0.0.1
> rpc.mountd: Received NULL request from host
> rpc.mountd: Received UMNT(/tmp/nfs) request from host
> rpc.mountd: authenticated unmount request from host:844 for /tmp/nfs
> (/tmp/nfs)
> rpc.mountd: Received NULL request from host
> rpc.mountd: Received NULL request from host
> rpc.mountd: Received MNT3(/tmp/nfs) request from host
> rpc.mountd: authenticated mount request from host:729 for /tmp/nfs
> (/tmp/nfs)
> rpc.mountd: nfsd_fh: inbuf '* 7
> \x0ab4100000000000dd2efb04e753f0980000000000000000'
> rpc.mountd: nfsd_fh: found 0x1f13380 path /tmp/nfs
> rpc.mountd: Received DUMP request from 127.0.0.1
> Segmentation fault
> .
>
>
> To gather more info I run rpc.mountd in gdb:
>
>
> Starting program: /usr/sbin/rpc.mountd -F
>
> Program received signal SIGSEGV, Segmentation fault.
> 0x00007ffff7b6f7a2 in xdr_string_internal () from /lib64/libc.so.6
>
> #0 0x00007ffff7b6f7a2 in xdr_string_internal () from /lib64/libc.so.6
> #1 0x0000000000409eee in xdr_name (xdrs=<value optimized out>,
> objp=<value optimized out>) at mount_xdr.c:83
> (...)
>
> Seems like two procedures (xdr_mountlist and xdr_mountbody) call one
> another infinitely until they fill the stack completely and then
> segfault occures.
>
> Is it known problem?
> Maybe I misconfigured or missed something?

I've investigated a little the sources and I noticed that probably there 
should be some pointer NULL-ed in mountlist_list() procedure like in 
patch I've attached.

Anyone can confirm that such a fix is ok?

--------------020308070404000209040409
Content-Type: text/x-patch;
 name="d1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="d1.diff"

diff -rNup nfs-utils-1.2.3_orig/utils/mountd/rmtab.c nfs-utils-1.2.3/utils/mountd/rmtab.c
--- nfs-utils-1.2.3/utils/mountd/rmtab.c	2010-09-28 14:24:16.000000000 +0200
+++ nfs-utils-1.2.3/utils/mountd/rmtab.c	2011-01-12 14:44:22.320000000 +0100
@@ -205,6 +205,7 @@ mountlist_list(void)
 	}
 	if (stb.st_mtime != last_mtime) {
 		mountlist_freeall(mlist);
+		mlist=NULL;
 		last_mtime = stb.st_mtime;
 
 		setrmtabent("r");

--------------020308070404000209040409--

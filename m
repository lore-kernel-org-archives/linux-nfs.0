Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtpo13.poczta.onet.pl ([213.180.142.144]:54522 "EHLO
	smtpo13.poczta.onet.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab1ALLkn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jan 2011 06:40:43 -0500
Received: from localhost.localdomain (unknown [83.238.22.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: sdrb@onet.eu)
	by smtp.poczta.onet.pl (Onet) with ESMTPSA id B243E2008417C
	for <linux-nfs@vger.kernel.org>; Wed, 12 Jan 2011 12:32:12 +0100 (CET)
Message-ID: <4D2D910F.1080703@onet.eu>
Date: Wed, 12 Jan 2011 12:31:27 +0100
From: sdrb <sdrb@onet.eu>
To: linux-nfs@vger.kernel.org
Subject: Issue in nfs-utils 1.2.3
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,


Recently I tried to upgrade nfs-utils to the newest nfs-utils 1.2.3. 
During tests I noticed that in some circumstances rpc.mountd
crashes with segmentation fault.
I'm testing it with 2.6.36 linux kernel.


Configuration of nfs-server:

   server# cat /etc/exports
   /export         *(rw)
   /tmp/nfs        *(rw)


The scenario how to reproduce the issue:

   server# rpc.mountd -F -d all
   server# showmount -a 127.0.0.1
   host# umount /mnt/nfs2 ; mount -t nfs server:/tmp/nfs /mnt/nfs2 -o 
nfsvers=3,nolock
   server# showmount -a 127.0.0.1


and after spawning showmount for the second time I got two segmentation 
faults: at showmount and at rpc.mountd.

Here is output from rpc.mountd:
   rpc.mountd: Received DUMP request from 127.0.0.1
   rpc.mountd: Received NULL request from host
   rpc.mountd: Received UMNT(/tmp/nfs) request from host
   rpc.mountd: authenticated unmount request from host:844 for /tmp/nfs 
(/tmp/nfs)
   rpc.mountd: Received NULL request from host
   rpc.mountd: Received NULL request from host
   rpc.mountd: Received MNT3(/tmp/nfs) request from host
   rpc.mountd: authenticated mount request from host:729 for /tmp/nfs 
(/tmp/nfs)
   rpc.mountd: nfsd_fh: inbuf '* 7 
\x0ab4100000000000dd2efb04e753f0980000000000000000'
   rpc.mountd: nfsd_fh: found 0x1f13380 path /tmp/nfs
   rpc.mountd: Received DUMP request from 127.0.0.1
   Segmentation fault
.


To gather more info I run rpc.mountd in gdb:


Starting program: /usr/sbin/rpc.mountd -F

   Program received signal SIGSEGV, Segmentation fault.
   0x00007ffff7b6f7a2 in xdr_string_internal () from /lib64/libc.so.6

   #0  0x00007ffff7b6f7a2 in xdr_string_internal () from /lib64/libc.so.6
   #1  0x0000000000409eee in xdr_name (xdrs=<value optimized out>, 
objp=<value optimized out>) at mount_xdr.c:83
   #2  0x0000000000409ff9 in xdr_mountbody (xdrs=0x63afd0, 
objp=0x63b530) at mount_xdr.c:103
   #3  0x00007ffff7b70e20 in xdr_reference_internal () from /lib64/libc.so.6
   #4  0x00007ffff7b70de1 in xdr_pointer () from /lib64/libc.so.6
   #5  0x0000000000409ed3 in xdr_mountlist (xdrs=<value optimized out>, 
objp=<value optimized out>) at mount_xdr.c:93
   #6  0x000000000040a02c in xdr_mountbody (xdrs=0x63afd0, 
objp=0x63b590) at mount_xdr.c:107
   #7  0x00007ffff7b70e20 in xdr_reference_internal () from /lib64/libc.so.6
   #8  0x00007ffff7b70de1 in xdr_pointer () from /lib64/libc.so.6
   #9  0x0000000000409ed3 in xdr_mountlist (xdrs=<value optimized out>, 
objp=<value optimized out>) at mount_xdr.c:93
   #10 0x000000000040a02c in xdr_mountbody (xdrs=0x63afd0, 
objp=0x63b470) at mount_xdr.c:107
   #11 0x00007ffff7b70e20 in xdr_reference_internal () from /lib64/libc.so.6
   #12 0x00007ffff7b70de1 in xdr_pointer () from /lib64/libc.so.6
   #13 0x0000000000409ed3 in xdr_mountlist (xdrs=<value optimized out>, 
objp=<value optimized out>) at mount_xdr.c:93
   #14 0x000000000040a02c in xdr_mountbody (xdrs=0x63afd0, 
objp=0x63b4d0) at mount_xdr.c:107
   #15 0x00007ffff7b70e20 in xdr_reference_internal () from /lib64/libc.so.6
   #16 0x00007ffff7b70de1 in xdr_pointer () from /lib64/libc.so.6
   #17 0x0000000000409ed3 in xdr_mountlist (xdrs=<value optimized out>, 
objp=<value optimized out>) at mount_xdr.c:93
   #18 0x000000000040a02c in xdr_mountbody (xdrs=0x63afd0, 
objp=0x63b530) at mount_xdr.c:107
   #19 0x00007ffff7b70e20 in xdr_reference_internal () from /lib64/libc.so.6
   #20 0x00007ffff7b70de1 in xdr_pointer () from /lib64/libc.so.6
   #21 0x0000000000409ed3 in xdr_mountlist (xdrs=<value optimized out>, 
objp=<value optimized out>) at mount_xdr.c:93
   #22 0x000000000040a02c in xdr_mountbody (xdrs=0x63afd0, 
objp=0x63b590) at mount_xdr.c:107
   #23 0x00007ffff7b70e20 in xdr_reference_internal () from /lib64/libc.so.6
   #24 0x00007ffff7b70de1 in xdr_pointer () from /lib64/libc.so.6
   #25 0x0000000000409ed3 in xdr_mountlist (xdrs=<value optimized out>, 
objp=<value optimized out>) at mount_xdr.c:93
   #26 0x000000000040a02c in xdr_mountbody (xdrs=0x63afd0, 
objp=0x63b470) at mount_xdr.c:107
   #27 0x00007ffff7b70e20 in xdr_reference_internal () from /lib64/libc.so.6
   #28 0x00007ffff7b70de1 in xdr_pointer () from /lib64/libc.so.6
   #29 0x0000000000409ed3 in xdr_mountlist (xdrs=<value optimized out>, 
objp=<value optimized out>) at mount_xdr.c:93
   #30 0x000000000040a02c in xdr_mountbody (xdrs=0x63afd0, 
objp=0x63b4d0) at mount_xdr.c:107
   #31 0x00007ffff7b70e20 in xdr_reference_internal () from /lib64/libc.so.6
   #32 0x00007ffff7b70de1 in xdr_pointer () from /lib64/libc.so.6
   #33 0x0000000000409ed3 in xdr_mountlist (xdrs=<value optimized out>, 
objp=<value optimized out>) at mount_xdr.c:93
   #34 0x000000000040a02c in xdr_mountbody (xdrs=0x63afd0, 
objp=0x63b530) at mount_xdr.c:107
   #35 0x00007ffff7b70e20 in xdr_reference_internal () from /lib64/libc.so.6
   #36 0x00007ffff7b70de1 in xdr_pointer () from /lib64/libc.so.6
   #37 0x0000000000409ed3 in xdr_mountlist (xdrs=<value optimized out>, 
objp=<value optimized out>) at mount_xdr.c:93
   #38 0x000000000040a02c in xdr_mountbody (xdrs=0x63afd0, 
objp=0x63b590) at mount_xdr.c:107
   #39 0x00007ffff7b70e20 in xdr_reference_internal () from /lib64/libc.so.6
   (...)

Seems like two procedures (xdr_mountlist and xdr_mountbody) call one 
another infinitely until they fill the stack completely and then 
segfault occures.

Is it known problem?
Maybe I misconfigured or missed something?


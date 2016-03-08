Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mtareserve88.acsu.buffalo.edu ([128.205.6.187]:36457 "EHLO
	mtareserve1.acsu.buffalo.edu" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750701AbcCHTa5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Mar 2016 14:30:57 -0500
Received: from localmaile.acsu.buffalo.edu (localmaile.acsu.buffalo.edu [128.205.4.3])
	by mtareserve1.acsu.buffalo.edu (Postfix) with ESMTP id 2B1CFDAF5BE
	for <linux-nfs@vger.kernel.org>; Tue,  8 Mar 2016 14:30:56 -0500 (EST)
Received: from localmaile.acsu.buffalo.edu (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id 1EDB7160071
	for <linux-nfs@vger.kernel.org>; Tue,  8 Mar 2016 14:30:56 -0500 (EST)
Received: from localmaile.acsu.buffalo.edu (localhost [127.0.0.1])
	by localmaile.acsu.buffalo.edu (Postfix) with ESMTP id BBB8C160082
	for <linux-nfs@vger.kernel.org>; Tue,  8 Mar 2016 14:30:55 -0500 (EST)
Received: from smtp.buffalo.edu (smtp4.acsu.buffalo.edu [128.205.5.229])
	by localmaile.acsu.buffalo.edu (Prefixe) with ESMTP id B9D4D160071
	for <linux-nfs@vger.kernel.org>; Tue,  8 Mar 2016 14:30:55 -0500 (EST)
Received: from flyline.acsu.buffalo.edu (porkchopexpress.acsu.buffalo.edu [128.205.123.27])
	by smtp.buffalo.edu (Postfix) with ESMTP id B455EE1B0F6
	for <linux-nfs@vger.kernel.org>; Tue,  8 Mar 2016 14:30:55 -0500 (EST)
Message-ID: <56DF286F.3010704@buffalo.edu>
Date: Tue, 08 Mar 2016 14:30:55 -0500
From: Mark Valites <mvalites@buffalo.edu>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: RH 7 nfs-utils update causes segfault
References: <56DDA2C2.3010806@buffalo.edu> <alpine.OSX.2.19.9992.1603071059490.66950@dhcp0201.cthon.org> <56DDABE2.3040204@buffalo.edu> <alpine.OSX.2.19.9992.1603071443060.66950@dhcp0201.cthon.org> <56DF0497.6090407@buffalo.edu> <alpine.OSX.2.19.9992.1603081319550.78938@planck.local> <56DF1C65.9090007@buffalo.edu> <alpine.OSX.2.19.9992.1603081406260.78938@planck.local>
In-Reply-To: <alpine.OSX.2.19.9992.1603081406260.78938@planck.local>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/08/2016 02:07 PM, Benjamin Coddington wrote:

> Before the first 'continue' use 'handle SIG37 nostop'..

I get a segfault that way:

GNU gdb (GDB) Red Hat Enterprise Linux 7.6.1-80.el7
Copyright (C) 2013 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later 
<http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-redhat-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Attaching to process 473
Reading symbols from /usr/sbin/rpc.gssd...Reading symbols from 
/usr/lib/debug/usr/sbin/rpc.gssd.debug...done.
done.
Reading symbols from /lib64/libtirpc.so.1...Reading symbols from 
/lib64/libtirpc.so.1...(no debugging symbols found)...done.
(no debugging symbols found)...done.
Loaded symbols for /lib64/libtirpc.so.1
Reading symbols from /lib64/libgssapi_krb5.so.2...Reading symbols from 
/usr/lib/debug/usr/lib64/libgssapi_krb5.so.2.2.debug...done.
done.
Loaded symbols for /lib64/libgssapi_krb5.so.2
Reading symbols from /lib64/libkrb5.so.3...Reading symbols from 
/usr/lib/debug/usr/lib64/libkrb5.so.3.3.debug...done.
done.
Loaded symbols for /lib64/libkrb5.so.3
Reading symbols from /lib64/libk5crypto.so.3...Reading symbols from 
/usr/lib/debug/usr/lib64/libk5crypto.so.3.1.debug...done.
done.
Loaded symbols for /lib64/libk5crypto.so.3
Reading symbols from /lib64/libcom_err.so.2...Reading symbols from 
/usr/lib/debug/usr/lib64/libcom_err.so.2.1.debug...done.
done.
Loaded symbols for /lib64/libcom_err.so.2
Reading symbols from /lib64/libc.so.6...Reading symbols from 
/usr/lib/debug/usr/lib64/libc-2.17.so.debug...done.
done.
Loaded symbols for /lib64/libc.so.6
Reading symbols from /lib64/libnsl.so.1...Reading symbols from 
/usr/lib/debug/usr/lib64/libnsl-2.17.so.debug...done.
done.
Loaded symbols for /lib64/libnsl.so.1
Reading symbols from /lib64/libpthread.so.0...Reading symbols from 
/usr/lib/debug/usr/lib64/libpthread-2.17.so.debug...done.
done.
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib64/libthread_db.so.1".
Loaded symbols for /lib64/libpthread.so.0
Reading symbols from /lib64/libkrb5support.so.0...Reading symbols from 
/usr/lib/debug/usr/lib64/libkrb5support.so.0.1.debug...done.
done.
Loaded symbols for /lib64/libkrb5support.so.0
Reading symbols from /lib64/libdl.so.2...Reading symbols from 
/usr/lib/debug/usr/lib64/libdl-2.17.so.debug...done.
done.
Loaded symbols for /lib64/libdl.so.2
Reading symbols from /lib64/libkeyutils.so.1...Reading symbols from 
/usr/lib/debug/usr/lib64/libkeyutils.so.1.5.debug...done.
done.
Loaded symbols for /lib64/libkeyutils.so.1
Reading symbols from /lib64/libresolv.so.2...Reading symbols from 
/usr/lib/debug/usr/lib64/libresolv-2.17.so.debug...done.
done.
Loaded symbols for /lib64/libresolv.so.2
Reading symbols from /lib64/ld-linux-x86-64.so.2...Reading symbols from 
/usr/lib/debug/usr/lib64/ld-2.17.so.debug...done.
done.
Loaded symbols for /lib64/ld-linux-x86-64.so.2
Reading symbols from /lib64/libselinux.so.1...Reading symbols from 
/usr/lib/debug/usr/lib64/libselinux.so.1.debug...done.
done.
Loaded symbols for /lib64/libselinux.so.1
Reading symbols from /lib64/libpcre.so.1...Reading symbols from 
/lib64/libpcre.so.1...(no debugging symbols found)...done.
(no debugging symbols found)...done.
Loaded symbols for /lib64/libpcre.so.1
Reading symbols from /lib64/liblzma.so.5...Reading symbols from 
/lib64/liblzma.so.5...(no debugging symbols found)...done.
(no debugging symbols found)...done.
Loaded symbols for /lib64/liblzma.so.5
Reading symbols from /usr/lib64/gssproxy/proxymech.so...Reading symbols 
from /usr/lib/debug/usr/lib64/gssproxy/proxymech.so.debug...done.
done.
Loaded symbols for /usr/lib64/gssproxy/proxymech.so
Reading symbols from /lib64/libgssrpc.so.4...Reading symbols from 
/usr/lib/debug/usr/lib64/libgssrpc.so.4.2.debug...done.
done.
Loaded symbols for /lib64/libgssrpc.so.4
0x00007ff64f5a6be9 in __GI_ppoll (fds=fds@entry=0x7ff6518b8b50, 
nfds=nfds@entry=1024, timeout=<optimized out>, timeout@entry=0x0, 
sigmask=sigmask@entry=0x7ffce9f91570)
     at ../sysdeps/unix/sysv/linux/ppoll.c:51
51          result = INLINE_SYSCALL (ppoll, 5, fds, nfds, timeout, 
sigmask, _NSIG / 8);
Missing separate debuginfos, use: debuginfo-install 
libtirpc-0.2.4-0.6.el7.x86_64 pcre-8.32-15.el7.x86_64 
xz-libs-5.1.2-12alpha.el7.x86_64
(gdb) handle SIG37 nostop
Signal        Stop      Print   Pass to program Description
SIG37         No        Yes     Yes             Real-time event 37
(gdb) continue
Continuing.

Program received signal SIG37, Real-time event 37.

Program received signal SIG37, Real-time event 37.

Program received signal SIG37, Real-time event 37.

Program received signal SIG37, Real-time event 37.

Program received signal SIG37, Real-time event 37.

Program received signal SIGSEGV, Segmentation fault.
__strcmp_ssse3 () at ../sysdeps/x86_64/strcmp.S:212
212             movlpd  (%rdi), %xmm1
(gdb) continue
Continuing.

Program terminated with signal SIGSEGV, Segmentation fault.
The program no longer exists.
(gdb)

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48242 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750817AbcCHSV3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Mar 2016 13:21:29 -0500
Date: Tue, 8 Mar 2016 13:21:27 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Mark Valites <mvalites@buffalo.edu>
cc: linux-nfs@vger.kernel.org
Subject: Re: RH 7 nfs-utils update causes segfault
In-Reply-To: <56DF0497.6090407@buffalo.edu>
Message-ID: <alpine.OSX.2.19.9992.1603081319550.78938@planck.local>
References: <56DDA2C2.3010806@buffalo.edu> <alpine.OSX.2.19.9992.1603071059490.66950@dhcp0201.cthon.org> <56DDABE2.3040204@buffalo.edu> <alpine.OSX.2.19.9992.1603071443060.66950@dhcp0201.cthon.org> <56DF0497.6090407@buffalo.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 8 Mar 2016, Mark Valites wrote:

> On 03/07/2016 02:49 PM, Benjamin Coddington wrote:
>
> > Best bet would be to attache a debugger to rpc.gssd and get a stack trace of
> > it when it crashes.  That will give us something to work from.
> >
> > You can do that with gdb -p <pid of gssd>.  Something like `gdb -p $(pidof
> > rpc.gssd)` will work -- then type "continue" to let the process continue to
> > run.  When it fails you can enter "bt" to emit a back trace.  That
> > information would be very helpful.
>
> Thank you for the gdb usage suggestion - I needed it...
>
> Here's the output:
>
>
> GNU gdb (GDB) Red Hat Enterprise Linux 7.6.1-80.el7
> Copyright (C) 2013 Free Software Foundation, Inc.
> License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
> This is free software: you are free to change and redistribute it.
> There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
> and "show warranty" for details.
> This GDB was configured as "x86_64-redhat-linux-gnu".
> For bug reporting instructions, please see:
> <http://www.gnu.org/software/gdb/bugs/>.
> Attaching to process 492
> Reading symbols from /usr/sbin/rpc.gssd...Reading symbols from
> /usr/lib/debug/usr/sbin/rpc.gssd.debug...done.
> done.
> Reading symbols from /lib64/libtirpc.so.1...Reading symbols from
> /lib64/libtirpc.so.1...(no debugging symbols found)...done.
> (no debugging symbols found)...done.
> Loaded symbols for /lib64/libtirpc.so.1
> Reading symbols from /lib64/libgssapi_krb5.so.2...Reading symbols from
> /usr/lib/debug/usr/lib64/libgssapi_krb5.so.2.2.debug...done.
> done.
> Loaded symbols for /lib64/libgssapi_krb5.so.2
> Reading symbols from /lib64/libkrb5.so.3...Reading symbols from
> /usr/lib/debug/usr/lib64/libkrb5.so.3.3.debug...done.
> done.
> Loaded symbols for /lib64/libkrb5.so.3
> Reading symbols from /lib64/libk5crypto.so.3...Reading symbols from
> /usr/lib/debug/usr/lib64/libk5crypto.so.3.1.debug...done.
> done.
> Loaded symbols for /lib64/libk5crypto.so.3
> Reading symbols from /lib64/libcom_err.so.2...Reading symbols from
> /usr/lib/debug/usr/lib64/libcom_err.so.2.1.debug...done.
> done.
> Loaded symbols for /lib64/libcom_err.so.2
> Reading symbols from /lib64/libc.so.6...Reading symbols from
> /usr/lib/debug/usr/lib64/libc-2.17.so.debug...done.
> done.
> Loaded symbols for /lib64/libc.so.6
> Reading symbols from /lib64/libnsl.so.1...Reading symbols from
> /usr/lib/debug/usr/lib64/libnsl-2.17.so.debug...done.
> done.
> Loaded symbols for /lib64/libnsl.so.1
> Reading symbols from /lib64/libpthread.so.0...Reading symbols from
> /usr/lib/debug/usr/lib64/libpthread-2.17.so.debug...done.
> done.
> [Thread debugging using libthread_db enabled]
> Using host libthread_db library "/lib64/libthread_db.so.1".
> Loaded symbols for /lib64/libpthread.so.0
> Reading symbols from /lib64/libkrb5support.so.0...Reading symbols from
> /usr/lib/debug/usr/lib64/libkrb5support.so.0.1.debug...done.
> done.
> Loaded symbols for /lib64/libkrb5support.so.0
> Reading symbols from /lib64/libdl.so.2...Reading symbols from
> /usr/lib/debug/usr/lib64/libdl-2.17.so.debug...done.
> done.
> Loaded symbols for /lib64/libdl.so.2
> Reading symbols from /lib64/libkeyutils.so.1...Reading symbols from
> /usr/lib/debug/usr/lib64/libkeyutils.so.1.5.debug...done.
> done.
> Loaded symbols for /lib64/libkeyutils.so.1
> Reading symbols from /lib64/libresolv.so.2...Reading symbols from
> /usr/lib/debug/usr/lib64/libresolv-2.17.so.debug...done.
> done.
> Loaded symbols for /lib64/libresolv.so.2
> Reading symbols from /lib64/ld-linux-x86-64.so.2...Reading symbols from
> /usr/lib/debug/usr/lib64/ld-2.17.so.debug...done.
> done.
> Loaded symbols for /lib64/ld-linux-x86-64.so.2
> Reading symbols from /lib64/libselinux.so.1...Reading symbols from
> /usr/lib/debug/usr/lib64/libselinux.so.1.debug...done.
> done.
> Loaded symbols for /lib64/libselinux.so.1
> Reading symbols from /lib64/libpcre.so.1...Reading symbols from
> /lib64/libpcre.so.1...(no debugging symbols found)...done.
> (no debugging symbols found)...done.
> Loaded symbols for /lib64/libpcre.so.1
> Reading symbols from /lib64/liblzma.so.5...Reading symbols from
> /lib64/liblzma.so.5...(no debugging symbols found)...done.
> (no debugging symbols found)...done.
> Loaded symbols for /lib64/liblzma.so.5
> Reading symbols from /usr/lib64/gssproxy/proxymech.so...Reading symbols from
> /usr/lib/debug/usr/lib64/gssproxy/proxymech.so.debug...done.
> done.
> Loaded symbols for /usr/lib64/gssproxy/proxymech.so
> Reading symbols from /lib64/libgssrpc.so.4...Reading symbols from
> /usr/lib/debug/usr/lib64/libgssrpc.so.4.2.debug...done.
> done.
> Loaded symbols for /lib64/libgssrpc.so.4
> 0x00007f4cd7ba4be9 in __GI_ppoll (fds=fds@entry=0x7f4cd9dc8b50,
> nfds=nfds@entry=1024, timeout=<optimized out>, timeout@entry=0x0,
> sigmask=sigmask@entry=0x7ffdd6f44770)
>     at ../sysdeps/unix/sysv/linux/ppoll.c:51
> 51          result = INLINE_SYSCALL (ppoll, 5, fds, nfds, timeout, sigmask,
> _NSIG / 8);
> Missing separate debuginfos, use: debuginfo-install
> libtirpc-0.2.4-0.6.el7.x86_64 pcre-8.32-15.el7.x86_64
> xz-libs-5.1.2-12alpha.el7.x86_64
> (gdb) continue
> Continuing.
>
> Program received signal SIG37, Real-time event 37.
> 0x00007f4cd7ba4be9 in __GI_ppoll (fds=fds@entry=0x7f4cd9dc8b50,
> nfds=nfds@entry=1024, timeout=<optimized out>, timeout@entry=0x0,
> sigmask=sigmask@entry=0x7ffdd6f44770)
>     at ../sysdeps/unix/sysv/linux/ppoll.c:51
> 51          result = INLINE_SYSCALL (ppoll, 5, fds, nfds, timeout, sigmask,
> _NSIG / 8);
> (gdb) bt
> #0  0x00007f4cd7ba4be9 in __GI_ppoll (fds=fds@entry=0x7f4cd9dc8b50,
> nfds=nfds@entry=1024, timeout=<optimized out>, timeout@entry=0x0,
> sigmask=sigmask@entry=0x7ffdd6f44770)
>     at ../sysdeps/unix/sysv/linux/ppoll.c:51
> #1  0x00007f4cd8c30587 in ppoll (__ss=0x7ffdd6f44770, __timeout=0x0,
> __nfds=1024, __fds=0x7f4cd9dc8b50) at /usr/include/bits/poll2.h:77
> #2  gssd_poll (nfds=1024, fds=0x7f4cd9dc8b50) at gssd_main_loop.c:194
> #3  gssd_run () at gssd_main_loop.c:258
> #4  0x00007f4cd8c2f11a in main (argc=<optimized out>, argv=0x7ffdd6f449d8) at
> gssd.c:216


That's weird -- you're getting SIG37 - I don't know what that could be.  Can
you just do another 'continue' there?  If not, can you do 'ptype $_siginfo'
there?

Ben

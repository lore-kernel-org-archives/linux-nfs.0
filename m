Return-Path: linux-nfs-owner@vger.kernel.org
Received: from master.debian.org ([82.195.75.110]:37565 "EHLO
	master.debian.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbaFGAqn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2014 20:46:43 -0400
Date: Sat, 7 Jun 2014 10:21:02 +1000
From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
To: linux-nfs@vger.kernel.org
Cc: 750792@bugs.debian.org, Jason Alavaliant <alavaliant@ra09.com>
Subject: Re: rpcbind: rpcinfo segfaults
Message-ID: <20140607002102.GA2398@master.debian.org>
References: <20140606230328.3222.73525.reportbug@grigorig.ra09.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20140606230328.3222.73525.reportbug@grigorig.ra09.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2014-06-07 11:03:28 +1200, Jason Alavaliant wrote:
> Package: rpcbind
> Version: 0.2.1-3
> Severity: important
> 
> Dear Maintainer,
> 
> In the last few days the rpcinfo command has started to segfault for
> me.  (I'm not 100% sure but it may have started directly after I
> updated my libc6 package to 2.19-1)
>
> I'm seeing in /var/log/syslog entries like
>
> Jun  7 10:52:02 grigorig kernel: [ 1085.923616] traps: rpcinfo[3160] general protection ip:7f940ff37218 sp:7ffff83d1e38 error:0 in libpthread-2.19.so[7f940ff26000+18000]
>
> (which come from nfs-common trying to call it when it's init script
> runs).
> 
> Running it directly from a shell results in a segfault;
> $ /usr/sbin/rpcinfo 
> Segmentation fault
> 
> Here is what I get running it through gdb
> 
> $ gdb /usr/sbin/rpcinfo 
> GNU gdb (GDB) 7.6.2 (Debian 7.6.2-1.1+b1)
> Copyright (C) 2013 Free Software Foundation, Inc.
> License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
> This is free software: you are free to change and redistribute it.
> There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
> and "show warranty" for details.
> This GDB was configured as "x86_64-linux-gnu".
> For bug reporting instructions, please see:
> <http://www.gnu.org/software/gdb/bugs/>...
> Reading symbols from /usr/sbin/rpcinfo...(no debugging symbols found)...done.
> (gdb) run
> Starting program: /usr/sbin/rpcinfo 
> warning: Could not load shared library symbols for linux-vdso.so.1.
> Do you need "set solib-search-path" or "set sysroot"?
> [Thread debugging using libthread_db enabled]
> Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
> 
> Program received signal SIGSEGV, Segmentation fault.
> __lll_unlock_elision (lock=0x7ffff7ddafe0 <authnone_lock>, private=0) at ../nptl/sysdeps/unix/sysv/linux/x86/elision-unlock.c:29
> 29      ../nptl/sysdeps/unix/sysv/linux/x86/elision-unlock.c: No such file or directory.
> (gdb) bt
> #0  __lll_unlock_elision (lock=0x7ffff7ddafe0 <authnone_lock>, private=0) at ../nptl/sysdeps/unix/sysv/linux/x86/elision-unlock.c:29
> #1  0x00007ffff7bbc9b1 in ?? () from /lib/x86_64-linux-gnu/libtirpc.so.1
> #2  0x00007ffff7bc17f0 in ?? () from /lib/x86_64-linux-gnu/libtirpc.so.1
> #3  0x0000000000403f8d in ?? ()
> #4  0x0000000000401b22 in ?? ()
> #5  0x00007ffff7404b45 in __libc_start_main (main=0x401760, argc=1, argv=0x7fffffffe228, init=<optimized out>, fini=<optimized out>, rtld_fini=<optimized out>, 
>     stack_end=0x7fffffffe218) at libc-start.c:287
> #6  0x0000000000402591 in ?? ()
> (gdb) 
> 
> Thanks
> -J
> 
> -- System Information:
> Debian Release: jessie/sid
>   APT prefers unstable
>   APT policy: (500, 'unstable'), (1, 'experimental')
> Architecture: amd64 (x86_64)
> Foreign Architectures: i386
> 
> Kernel: Linux 3.14-1-amd64 (SMP w/4 CPU cores)
> Locale: LANG=en_NZ, LC_CTYPE=en_NZ (charmap=ISO-8859-1)
> Shell: /bin/sh linked to /bin/dash
> 
> Versions of packages rpcbind depends on:
> ii  initscripts  2.88dsf-53
> ii  insserv      1.14.0-5
> ii  libc-bin     2.19-1
> ii  libc6        2.19-1
> ii  libtirpc1    0.2.2-7
> ii  libwrap0     7.6.q-25
> ii  lsb-base     4.1+Debian12
> 
> rpcbind recommends no packages.
> 
> rpcbind suggests no packages.
> 
> -- no debconf information

Comments, Please.

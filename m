Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35823 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867AbcCHUhb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Mar 2016 15:37:31 -0500
Date: Tue, 8 Mar 2016 15:37:29 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Mark Valites <mvalites@buffalo.edu>
cc: linux-nfs@vger.kernel.org
Subject: Re: RH 7 nfs-utils update causes segfault
In-Reply-To: <56DF35A1.1000007@buffalo.edu>
Message-ID: <alpine.OSX.2.19.9992.1603081532310.78938@planck.local>
References: <56DDA2C2.3010806@buffalo.edu> <alpine.OSX.2.19.9992.1603071059490.66950@dhcp0201.cthon.org> <56DDABE2.3040204@buffalo.edu> <alpine.OSX.2.19.9992.1603071443060.66950@dhcp0201.cthon.org> <56DF0497.6090407@buffalo.edu>
 <alpine.OSX.2.19.9992.1603081319550.78938@planck.local> <56DF1C65.9090007@buffalo.edu> <alpine.OSX.2.19.9992.1603081406260.78938@planck.local> <56DF286F.3010704@buffalo.edu> <alpine.OSX.2.19.9992.1603081513100.78938@planck.local>
 <56DF35A1.1000007@buffalo.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 8 Mar 2016, Mark Valites wrote:

> On 03/08/2016 03:16 PM, Benjamin Coddington wrote:
>
> > That's where we want the backtrace; that's when you should do 'bt'.  Feel
> > free to leave out everything else.
>
> Wow - Sorry about that.
>
> (gdb) handle SIG37 nostop
> Signal        Stop      Print   Pass to program Description
> SIG37         No        Yes     Yes             Real-time event 37
> (gdb) continue
> Continuing.
>
> Program received signal SIG37, Real-time event 37.
>
> Program received signal SIG37, Real-time event 37.
>
> Program received signal SIG37, Real-time event 37.
>
> Program received signal SIG37, Real-time event 37.
>
> Program received signal SIG37, Real-time event 37.
>
> Program received signal SIGSEGV, Segmentation fault.
> __strcmp_ssse3 () at ../sysdeps/x86_64/strcmp.S:212
> 212             movlpd  (%rdi), %xmm1
> (gdb) bt
> #0  __strcmp_ssse3 () at ../sysdeps/x86_64/strcmp.S:212
> #1  0x00007fec0dfb60f4 in find_keytab_entry (context=0x7fec0f82d6d0,
> kt=0x7fec0f829a10, tgtname=tgtname@entry=0x7fec0f829910
> "ubfs1.itorg.ad.buffalo.edu",
>     kte=kte@entry=0x7fffc8ca1ec0, svcnames=svcnames@entry=0x7fffc8ca1e90) at
> krb5_util.c:894
> #2  0x00007fec0dfb6ded in gssd_refresh_krb5_machine_credential
> (hostname=0x7fec0f829910 "ubfs1.itorg.ad.buffalo.edu", ple=ple@entry=0x0,
> service=service@entry=0x0)
>     at krb5_util.c:1311
> #3  0x00007fec0dfb4030 in krb5_use_machine_creds
> (clp=clp@entry=0x7fec0f82bcb0, uid=uid@entry=0, tgtname=tgtname@entry=0x0,
> service=service@entry=0x0,
>     rpc_clnt=rpc_clnt@entry=0x7fffc8ca2000) at gssd_proc.c:1086
> #4  0x00007fec0dfb4416 in process_krb5_upcall (clp=clp@entry=0x7fec0f82bcb0,
> uid=0, fd=13, tgtname=tgtname@entry=0x0, service=service@entry=0x0) at
> gssd_proc.c:1222
> #5  0x00007fec0dfb4d03 in handle_gssd_upcall (clp=clp@entry=0x7fec0f82bcb0) at
> gssd_proc.c:1413
> #6  0x00007fec0dfb264e in scan_poll_results (ret=1) at gssd_main_loop.c:85
> #7  gssd_poll (nfds=<optimized out>, fds=<optimized out>) at
> gssd_main_loop.c:201
> #8  gssd_run () at gssd_main_loop.c:258
> #9  0x00007fec0dfb111a in main (argc=<optimized out>, argv=0x7fffc8ca2418) at
> gssd.c:216
> (gdb) continue
> Continuing.
>
> Program terminated with signal SIGSEGV, Segmentation fault.
> The program no longer exists.
> (gdb)
>
> FWIW, the ubfs1.itorg.ad.buffalo.edu hostname mentioned in the backtrace is
> the nfs server.

OK, that's pretty certainly this bug:
https://bugzilla.redhat.com/show_bug.cgi?id=1313090

You can add your email to the CC list there, and leave a comment stating
you're hitting it as well.  If you have Red Hat support, you can open a
support case.

The patch in that BZ should fix it up for you, or you can use the previous
nfs-utils version until that BZ changes to CLOSED, at which time a fixed
nfs-utils pacakge will be available.

Nice job working through gdb over email, and sorry for the trouble.

Ben

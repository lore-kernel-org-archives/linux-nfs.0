Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56427 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752262Ab2HQRS4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Aug 2012 13:18:56 -0400
Date: Fri, 17 Aug 2012 13:18:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux-kernel <linux-kernel@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.0+ NFS issues (bisected)
Message-ID: <20120817171854.GA14015@fieldses.org>
References: <1338469169.2420.7.camel@lade.trondhjem.org>
 <4FC77128.9090206@msgid.tls.msk.ru>
 <1338471975.7732.5.camel@lade.trondhjem.org>
 <4FC77755.5060606@msgid.tls.msk.ru>
 <4FFC2573.8040804@msgid.tls.msk.ru>
 <20120712125303.GC16822@fieldses.org>
 <502DA4E8.9050800@msgid.tls.msk.ru>
 <20120817145616.GC11172@fieldses.org>
 <20120817160057.GE11172@fieldses.org>
 <502E7B86.3060702@msgid.tls.msk.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <502E7B86.3060702@msgid.tls.msk.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 17, 2012 at 09:12:38PM +0400, Michael Tokarev wrote:
> On 17.08.2012 20:00, J. Bruce Fields wrote:
> []> Uh, if I grepped my way through this right: it looks like it's the
> > "memory" column of the "TCP" row of /proc/net/protocols; might be
> > interesting to see how that's changing over time.
> 
> This file does not look interesting.  Memory usage does not jump,
> there's no high increase either.
> 
> But there's something else which is interesting here.
> 
> I noticed that in perf top, the top consumer of CPU is svc_recv()
> (I mentioned this in the start of this thread).  So I looked how
> this routine is called from nfsd.  And here we go.
> 
> fs/nfsd/nfssvc.c:
> 
> /*
>  * This is the NFS server kernel thread
>  */
> static int
> nfsd(void *vrqstp)
> {
> ...
>         /*
>          * The main request loop
>          */
>         for (;;) {
>                 /*
>                  * Find a socket with data available and call its
>                  * recvfrom routine.
>                  */
> int i = 0;
>                 while ((err = svc_recv(rqstp, 60*60*HZ)) == -EAGAIN)
>                         ++i;
> printk(KERN_ERR "calling svc_recv: %d times (err=%d)\n", i, err);
>                 if (err == -EINTR)
>                         break;
> ...
> 
> (I added the "i" counter and the printk).  And here's the output:
> 
> [19626.401136] calling svc_recv: 0 times (err=212)
> [19626.405059] calling svc_recv: 1478 times (err=212)
> [19626.409512] calling svc_recv: 1106 times (err=212)
> [19626.543020] calling svc_recv: 0 times (err=212)
> [19626.543059] calling svc_recv: 0 times (err=212)
> [19626.548074] calling svc_recv: 0 times (err=212)
> [19626.549515] calling svc_recv: 0 times (err=212)
> [19626.552320] calling svc_recv: 0 times (err=212)
> [19626.553503] calling svc_recv: 0 times (err=212)
> [19626.556007] calling svc_recv: 0 times (err=212)
> [19626.557152] calling svc_recv: 0 times (err=212)
> [19626.560109] calling svc_recv: 0 times (err=212)
> [19626.560943] calling svc_recv: 0 times (err=212)
> [19626.565315] calling svc_recv: 1067 times (err=212)
> [19626.569735] calling svc_recv: 2571 times (err=212)
> [19626.574150] calling svc_recv: 3842 times (err=212)
> [19626.581914] calling svc_recv: 2891 times (err=212)
> [19626.583072] calling svc_recv: 1247 times (err=212)
> [19626.616885] calling svc_recv: 0 times (err=212)
> [19626.616952] calling svc_recv: 0 times (err=212)
> [19626.622889] calling svc_recv: 0 times (err=212)
> [19626.624518] calling svc_recv: 0 times (err=212)
> [19626.627118] calling svc_recv: 0 times (err=212)
> [19626.629735] calling svc_recv: 0 times (err=212)
> [19626.631777] calling svc_recv: 0 times (err=212)
> [19626.633986] calling svc_recv: 0 times (err=212)
> [19626.636746] calling svc_recv: 0 times (err=212)
> [19626.637692] calling svc_recv: 0 times (err=212)
> [19626.640769] calling svc_recv: 0 times (err=212)
> [19626.657852] calling svc_recv: 0 times (err=212)
> [19626.661602] calling svc_recv: 0 times (err=212)
> [19626.670160] calling svc_recv: 0 times (err=212)
> [19626.671917] calling svc_recv: 0 times (err=212)
> [19626.684643] calling svc_recv: 0 times (err=212)
> [19626.684680] calling svc_recv: 0 times (err=212)
> [19626.812820] calling svc_recv: 0 times (err=212)
> [19626.814697] calling svc_recv: 0 times (err=212)
> [19626.817195] calling svc_recv: 0 times (err=212)
> [19626.820324] calling svc_recv: 0 times (err=212)
> [19626.822855] calling svc_recv: 0 times (err=212)
> [19626.824823] calling svc_recv: 0 times (err=212)
> [19626.828016] calling svc_recv: 0 times (err=212)
> [19626.829021] calling svc_recv: 0 times (err=212)
> [19626.831970] calling svc_recv: 0 times (err=212)
> 
> > the stall begin:
> [19686.823135] calling svc_recv: 3670352 times (err=212)
> [19686.823524] calling svc_recv: 3659205 times (err=212)
> 
> > transfer continues
> [19686.854734] calling svc_recv: 0 times (err=212)
> [19686.860023] calling svc_recv: 0 times (err=212)
> [19686.887124] calling svc_recv: 0 times (err=212)
> [19686.895532] calling svc_recv: 0 times (err=212)
> [19686.903667] calling svc_recv: 0 times (err=212)
> [19686.922780] calling svc_recv: 0 times (err=212)
> 
> So we're calling svc_recv in a tight loop, eating
> all available CPU.  (The above is with just 2 nfsd
> threads).
> 
> Something is definitely wrong here.  And it happens mure more
> often after the mentioned commit (f03d78db65085).

Oh, neat.  Hm.  That commit doesn't really sound like the cause, then.
Is that busy-looping reproduceable on kernels before that commit?

--b.

From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: [NFS] nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10
Date: Mon, 25 Aug 2003 10:45:10 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200308251045.10907.bernd-schubert@web.de>
References: <200308231404.34087.hpj@urpla.net> <shsekzcjnbt.fsf@charged.uio.no> <200308240212.49348.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: nfs@lists.sourceforge.net
In-Reply-To: <200308240212.49348.bernd-schubert@web.de>
List-ID: <nfs.lists.sourceforge.net>

On Sunday 24 August 2003 02:12, Bernd Schubert wrote:
> On Saturday 23 August 2003 19:28, Trond Myklebust wrote:
> > >>>>> " " == Hans-Peter Jansen <hpj@urpla.net> writes:
> >      > Hi, after kernel update all my (diskless) systems clutter up
> >      > the syslog with:
> >      >
> >      > Aug 23 13:41:42 yogi kernel: nfs: server shrek not responding,
> >
> > Does the following patch help?
> >
> > Cheers,
> >   Trond
> >
> > --- linux-2.4.22-up/net/sunrpc/timer.c.orig	2002-08-14 17:52:52.000000000
> > -0700 +++ linux-2.4.22-up/net/sunrpc/timer.c	2003-08-23
> > 10:26:36.000000000 -0700 @@ -8,7 +8,7 @@
> >
> >  #define RPC_RTO_MAX (60*HZ)
> >  #define RPC_RTO_INIT (HZ/5)
> > -#define RPC_RTO_MIN (2)
> > +#define RPC_RTO_MIN (HZ/10)
> >
> >  void
> >  rpc_init_rtt(struct rpc_rtt *rt, long timeo)
>
> Hello,
>
> I also just had this problem with 2.4.22-rc2 and your patch is fixing it.
>
> Thanks,
> 	Bernd
>

Since today already 2.4.22-rc4 has been released, shouldn't that be posted to 
Marcelo as fast as possible?

Regards,	
	Bernd

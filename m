Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47628 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755491Ab0H3MLT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 08:11:19 -0400
Date: Mon, 30 Aug 2010 14:10:22 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
To: Neil Brown <neilb@suse.de>
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [REGRESSION PATCH] NFS: let NFS_V4 and NFSD_V4 enforce CRYPTO
Message-ID: <20100830121022.GA14459@pengutronix.de>
References: <20100825084912.GA10293@pengutronix.de> <1282727119-8295-1-git-send-email-u.kleine-koenig@pengutronix.de> <20100827061139.GA27851@pengutronix.de> <20100830082618.GA24402@pengutronix.de> <20100830203659.3b9884f6@notabene>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20100830203659.3b9884f6@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 30, 2010 at 08:36:59PM +1000, Neil Brown wrote:
> On Mon, 30 Aug 2010 10:26:18 +0200
> Uwe Kleine-König <u.kleine-koenig@pengutronix.de> wrote:
> 
> > [extending Cc: to contain Neil and linux-nfs]
> > 
> > On Fri, Aug 27, 2010 at 08:11:39AM +0200, Uwe Kleine-König wrote:
> > > On Wed, Aug 25, 2010 at 11:05:19AM +0200, Uwe Kleine-König wrote:
> 
> I would tend to wait more than 2 days between pings..

	ukl@octopus:~/gsrc/linux-2.6$ git rev-parse linus/master
	2bfc96a127bc1cc94d26bfaa40159966064f9c8c
	ukl@octopus:~/gsrc/linux-2.6$ git grep -E CRYPTO= linus/master arch/arm/configs/ | wc -l
	6
	ukl@octopus:~/gsrc/linux-2.6$ git grep -E NFSD?_V4 linus/master arch/arm/configs/ | wc -l
	37

So I think that at least 31 arm-defconfigs don't build because of this
issue.  And as this kind of error greatly hurts automatic bisection I
thought this to be critical enough to be a bit impatient.

> > > > This is a follow up to
> > > > 
> > > > 	df486a2 (NFS: Fix the selection of security flavours in Kconfig)
> > > > 
> > > > which broke (among others) arm/mx1_defconfig.
> > > > 
> > > > Moreover let NFS_V4 select RPCSEC_GSS_KRB5 again as it was before
> > > > df486a2.  This make the dependency more explicit than relying on the no
> > > > prompt + default y if !(NFS_V4 || NFSD_V4).
> 
> Maybe if you said a little bit about how it broke?
  LD      .tmp_vmlinux1
fs/built-in.o: In function `nfs_callback_authenticate':
compr_zlib.c:(.text+0x7c040): undefined reference to `svc_gss_principal'
make[2]: *** [.tmp_vmlinux1] Error 1
make[1]: *** [sub-make] Error 2
make: *** [all] Error 2

I can add this to the commit log.

> And I'm not sure of the point of the "recursive dependency" comment below...
I added this because if kconfig were a bit smarter it would select
CRYPTO, too, if asked to select RPCSEC_GSS_KRB5.  On the
linux-arm-kernel ML Catalin Marinas already thought about making kconfig
smarter and so I wanted to mark the symbol.
 
> I don't fully understand all the issues behind choosing between 'depends' and
> 'select' (why isn't is 'selects' I wonder - that would be more consistent...)
I think it's an imperative, not a normal present tense?!  And note this
is different.  Here it's not depend vs. select but select vs.

	config SOMESYMBOL
		prompt "sometext" if !(NFS_V4 || NFSD_V4)
		default y

So a dependency for NFS_V4 is hidden in net/sunrpc/Kconfig.

> But that patch seems to make sense to me.
Thanks, that's an Ack?

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-König            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

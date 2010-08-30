Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2486 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754918Ab0H3NvV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 09:51:21 -0400
Subject: Re: [REGRESSION PATCH] NFS: let NFS_V4 and NFSD_V4 enforce CRYPTO
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Cc: Neil Brown <neilb@suse.de>, Randy Dunlap <randy.dunlap@oracle.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
In-Reply-To: <20100830121022.GA14459@pengutronix.de>
References: <20100825084912.GA10293@pengutronix.de>
	 <1282727119-8295-1-git-send-email-u.kleine-koenig@pengutronix.de>
	 <20100827061139.GA27851@pengutronix.de>
	 <20100830082618.GA24402@pengutronix.de> <20100830203659.3b9884f6@notabene>
	 <20100830121022.GA14459@pengutronix.de>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 30 Aug 2010 09:50:24 -0400
Message-ID: <1283176224.7073.13.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-08-30 at 14:10 +0200, Uwe Kleine-König wrote:
> On Mon, Aug 30, 2010 at 08:36:59PM +1000, Neil Brown wrote:
> > On Mon, 30 Aug 2010 10:26:18 +0200
> > Uwe Kleine-König <u.kleine-koenig@pengutronix.de> wrote:
> > 
> > > [extending Cc: to contain Neil and linux-nfs]
> > > 
> > > On Fri, Aug 27, 2010 at 08:11:39AM +0200, Uwe Kleine-König wrote:
> > > > On Wed, Aug 25, 2010 at 11:05:19AM +0200, Uwe Kleine-König wrote:
> > 
> > I would tend to wait more than 2 days between pings..
>
> 	ukl@octopus:~/gsrc/linux-2.6$ git rev-parse linus/master
> 	2bfc96a127bc1cc94d26bfaa40159966064f9c8c
> 	ukl@octopus:~/gsrc/linux-2.6$ git grep -E CRYPTO= linus/master arch/arm/configs/ | wc -l
> 	6
> 	ukl@octopus:~/gsrc/linux-2.6$ git grep -E NFSD?_V4 linus/master arch/arm/configs/ | wc -l
> 	37
> 
> So I think that at least 31 arm-defconfigs don't build because of this
> issue.  And as this kind of error greatly hurts automatic bisection I
> thought this to be critical enough to be a bit impatient.

So, why aren't you first and foremost fixing the damned arm-defconfigs?
They are clearly broken if they are auto-selecting NFSv4 without CRYPTO
and RPCSEC_GSS.

> > > > > This is a follow up to
> > > > > 
> > > > > 	df486a2 (NFS: Fix the selection of security flavours in Kconfig)
> > > > > 
> > > > > which broke (among others) arm/mx1_defconfig.
> > > > > 
> > > > > Moreover let NFS_V4 select RPCSEC_GSS_KRB5 again as it was before
> > > > > df486a2.  This make the dependency more explicit than relying on the no
> > > > > prompt + default y if !(NFS_V4 || NFSD_V4).
> > 
> > Maybe if you said a little bit about how it broke?
>   LD      .tmp_vmlinux1
> fs/built-in.o: In function `nfs_callback_authenticate':
> compr_zlib.c:(.text+0x7c040): undefined reference to `svc_gss_principal'
> make[2]: *** [.tmp_vmlinux1] Error 1
> make[1]: *** [sub-make] Error 2
> make: *** [all] Error 2
> 
> I can add this to the commit log.

This is exactly the problem that Randy was seeing _before_ commit
df486a2, so just reverting that patch by adding the selects back into
NFSv4 is wrong.

The right thing to do here (aside from fixing the crummy defconfigs) is
rather to fix nfs_callback_authenticate() to stop depending on GSS
private interfaces such as svc_gss_principal().

> > And I'm not sure of the point of the "recursive dependency" comment below...
> I added this because if kconfig were a bit smarter it would select
> CRYPTO, too, if asked to select RPCSEC_GSS_KRB5.  On the
> linux-arm-kernel ML Catalin Marinas already thought about making kconfig
> smarter and so I wanted to mark the symbol.
>  
> > I don't fully understand all the issues behind choosing between 'depends' and
> > 'select' (why isn't is 'selects' I wonder - that would be more consistent...)
> I think it's an imperative, not a normal present tense?!  And note this
> is different.  Here it's not depend vs. select but select vs.
> 
> 	config SOMESYMBOL
> 		prompt "sometext" if !(NFS_V4 || NFSD_V4)
> 		default y
> 
> So a dependency for NFS_V4 is hidden in net/sunrpc/Kconfig.

You are simply not supposed to be given the option of turning it off if
NFSv4 is selected.

Trond

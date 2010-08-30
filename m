Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53062 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841Ab0H3Og2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 10:36:28 -0400
Date: Mon, 30 Aug 2010 16:36:11 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Neil Brown <neilb@suse.de>, Randy Dunlap <randy.dunlap@oracle.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [REGRESSION PATCH] NFS: let NFS_V4 and NFSD_V4 enforce CRYPTO
Message-ID: <20100830143611.GC14459@pengutronix.de>
References: <20100825084912.GA10293@pengutronix.de> <1282727119-8295-1-git-send-email-u.kleine-koenig@pengutronix.de> <20100827061139.GA27851@pengutronix.de> <20100830082618.GA24402@pengutronix.de> <20100830203659.3b9884f6@notabene> <20100830121022.GA14459@pengutronix.de> <1283176224.7073.13.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1283176224.7073.13.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello Trond,

On Mon, Aug 30, 2010 at 09:50:24AM -0400, Trond Myklebust wrote:
> On Mon, 2010-08-30 at 14:10 +0200, Uwe Kleine-König wrote:
> > On Mon, Aug 30, 2010 at 08:36:59PM +1000, Neil Brown wrote:
> > > On Mon, 30 Aug 2010 10:26:18 +0200
> > > Uwe Kleine-König <u.kleine-koenig@pengutronix.de> wrote:
> > > 
> > > > [extending Cc: to contain Neil and linux-nfs]
> > > > 
> > > > On Fri, Aug 27, 2010 at 08:11:39AM +0200, Uwe Kleine-König wrote:
> > > > > On Wed, Aug 25, 2010 at 11:05:19AM +0200, Uwe Kleine-König wrote:
> > > 
> > > I would tend to wait more than 2 days between pings..
> >
> > 	ukl@octopus:~/gsrc/linux-2.6$ git rev-parse linus/master
> > 	2bfc96a127bc1cc94d26bfaa40159966064f9c8c
> > 	ukl@octopus:~/gsrc/linux-2.6$ git grep -E CRYPTO= linus/master arch/arm/configs/ | wc -l
> > 	6
> > 	ukl@octopus:~/gsrc/linux-2.6$ git grep -E NFSD?_V4 linus/master arch/arm/configs/ | wc -l
> > 	37
> > 
> > So I think that at least 31 arm-defconfigs don't build because of this
> > issue.  And as this kind of error greatly hurts automatic bisection I
> > thought this to be critical enough to be a bit impatient.
> 
> So, why aren't you first and foremost fixing the damned arm-defconfigs?
They are not broken.  The problem is that it's possible to configure a
kernel that doesn't build.  Note the config resulting from the
mx1_defconfig target fully conform to the restrictions expressed in the
Kconfig files even if arch/arm/configs/mx1_defconfig doesn't.  So if
NFS_V4 was selecting CRYPTO (or CRYPTO would default to y in the
presence of NFS_V4) mx1_defconfig would enable it implicitly.

> They are clearly broken if they are auto-selecting NFSv4 without CRYPTO
> and RPCSEC_GSS.
> 
> > > > > > This is a follow up to
> > > > > > 
> > > > > > 	df486a2 (NFS: Fix the selection of security flavours in Kconfig)
> > > > > > 
> > > > > > which broke (among others) arm/mx1_defconfig.
> > > > > > 
> > > > > > Moreover let NFS_V4 select RPCSEC_GSS_KRB5 again as it was before
> > > > > > df486a2.  This make the dependency more explicit than relying on the no
> > > > > > prompt + default y if !(NFS_V4 || NFSD_V4).
> > > 
> > > Maybe if you said a little bit about how it broke?
> >   LD      .tmp_vmlinux1
> > fs/built-in.o: In function `nfs_callback_authenticate':
> > compr_zlib.c:(.text+0x7c040): undefined reference to `svc_gss_principal'
> > make[2]: *** [.tmp_vmlinux1] Error 1
> > make[1]: *** [sub-make] Error 2
> > make: *** [all] Error 2
> > 
> > I can add this to the commit log.
> 
> This is exactly the problem that Randy was seeing _before_ commit
> df486a2, so just reverting that patch by adding the selects back into
> NFSv4 is wrong.
If NFSD_V4 selects RPCSEC_GSS_KRB5 which in turn selects SUNRPC_GSS the
latter should be enabled in all builds that have NFSD_V4=y (assuming all
dependencies are fulfilled), no?

The problem that needed fixing before your commit was that
RPCSEC_GSS_KRB5 depended on EXPERIMENTAL while NFS_V4 did not (and so
the select RPCSEC_GSS_KRB5 done by NFS_V4 didn't work if EXPERIMENTAL
was unset.)  So the minimal fix would have been to remove the "&&
EXPERIMENTAL" from RPCSEC_GSS_KRB5.

Your commit additionally did the following:

 - change the default of RPCSEC_GSS_KRB5 to y if !(NFS_V4 || NFSD_V4)
 - let RPCSEC_GSS_KRB5 depend on CRYPTO (was *select* CRYPTO before)
 - express the dependency NFSD_V4 -> RPCSEC_GSS_KRB5 at the latter
   symbol (was expressed at NFSD_V4 before)

So because of the second change listed above now my situation is similar
to Randy's earlier, but my problem is I don't have CRYPTO while Randy's
was that he didn't have EXPERIMENTAL.  (That's what I guess, I didn't
read the corresponding thread.)

Subsuming the situation your commit fixed a problem but introduced a
very similar one.

> The right thing to do here (aside from fixing the crummy defconfigs) is
> rather to fix nfs_callback_authenticate() to stop depending on GSS
> private interfaces such as svc_gss_principal().
That would be OK for me, too.  Do you do it?  I guess this has to wait
for the next merge window, so I suggest to still take my patch.

> > > And I'm not sure of the point of the "recursive dependency" comment below...
> > I added this because if kconfig were a bit smarter it would select
> > CRYPTO, too, if asked to select RPCSEC_GSS_KRB5.  On the
> > linux-arm-kernel ML Catalin Marinas already thought about making kconfig
> > smarter and so I wanted to mark the symbol.
> >  
> > > I don't fully understand all the issues behind choosing between 'depends' and
> > > 'select' (why isn't is 'selects' I wonder - that would be more consistent...)
> > I think it's an imperative, not a normal present tense?!  And note this
> > is different.  Here it's not depend vs. select but select vs.
> > 
> > 	config SOMESYMBOL
> > 		prompt "sometext" if !(NFS_V4 || NFSD_V4)
> > 		default y
> > 
> > So a dependency for NFS_V4 is hidden in net/sunrpc/Kconfig.
> 
> You are simply not supposed to be given the option of turning it off if
> NFSv4 is selected.
I understand your construct, but I think it's non sensible to do it this
way.  You're hiding a dependency of NFS_V4 this way (to the developper,
not the user configuring the kernel).

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-König            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

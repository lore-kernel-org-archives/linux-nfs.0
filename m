Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:41298 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714Ab0H3Mdo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 08:33:44 -0400
Date: Mon, 30 Aug 2010 14:33:05 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
To: Neil Brown <neilb@suse.de>
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [REGRESSION PATCH] NFS: let NFS_V4 and NFSD_V4 enforce CRYPTO
Message-ID: <20100830123305.GB14459@pengutronix.de>
References: <20100825084912.GA10293@pengutronix.de> <1282727119-8295-1-git-send-email-u.kleine-koenig@pengutronix.de> <20100827061139.GA27851@pengutronix.de> <20100830082618.GA24402@pengutronix.de> <20100830203659.3b9884f6@notabene> <20100830121022.GA14459@pengutronix.de>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20100830121022.GA14459@pengutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 30, 2010 at 02:10:22PM +0200, Uwe Kleine-König wrote:
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
This is wrong, because the last line counts configs having both NFSD_V4
and NFS_V4 twice.  There are "only" 31 that have at least one of NFSD_V4
and NFS_V4.  But only one of these (at572d940hfek_defconfig) has CRYPTO
set, too.
 
> So I think that at least 31 arm-defconfigs don't build because of this
> issue.  And as this kind of error greatly hurts automatic bisection I
> thought this to be critical enough to be a bit impatient.
To extend the test to non-ARM land:

ukl@octopus:~/gsrc/linux-2.6$ git ls-tree -r --name-only linus/master | grep defconfig | xargs grep -l -E 'CONFIG_NFSD?_V4=' | xargs grep -L CONFIG_CRYPTO= | wc -l
108

(Thinking about it again probably not all of them are broken, because
there might be other symbols selecting CRYPTO.)

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-König            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

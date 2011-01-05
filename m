Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:40167 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752544Ab1AEUfV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 15:35:21 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
In-Reply-To: <AANLkTik214sj_wBJXhJMLRie34moG7ET1Xg62oQXsgxb@mail.gmail.com>
References: <1294254337.16957.13.camel@mulgrave.site>
	 <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
	 <1294256169.16957.18.camel@mulgrave.site>
	 <AANLkTik214sj_wBJXhJMLRie34moG7ET1Xg62oQXsgxb@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Jan 2011 20:35:17 +0000
Message-ID: <1294259717.16957.27.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-05 at 11:49 -0800, Linus Torvalds wrote:
> 2011/1/5 James Bottomley <James.Bottomley@hansenpartnership.com>:
> >>
> >> No, we really can't do that. Most of the time, the kmap() is the only
> >> way we access the page anyway, so flushing things would just be
> >> stupid. Why waste time and energy on doing something pointless?
> >
> > It's hardly pointless.  The kmap sets up an inequivalent alias in the
> > cache.
> 
> NO IT DOES NOT.

Well, it does ... but not in this case because the page is freshly
allocated (which I missed before) so it has no use cache colour yet.

James

> Stop arguing, when you are so wrong.
> 
> kmap() does not create any aliases. For low-memory, it just returns
> the physical address. No alias. And for high memory, there is no
> equivalent low memory address to alias _with_.
> 
> Now, when you actually mix multiple kmap's and you have a virtually
> based cache, then the kmap's obviously need to flush that particular
> page when switching between each other. But that has nothing to do
> with the actual page being kmap'ed, it's entirely an internal issue
> about the particular virtual memory area being re-used. And ARM (and
> any other virtually based CPU) already does that in __kunmap_atomic().
> 
> But notice the case of the low-mem. And understand that you are WRONG
> about the "inequivalent alias" thing.
> 
> So I repeat: this has absolutely *NOTHING* to do with kmap(). Stop blathering.
> 
> It's _purely_ an issue of vm_map_ram(). Nothing else.
> 
>                           Linus



Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51142 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752250Ab1AETuA convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 14:50:00 -0500
In-Reply-To: <1294256169.16957.18.camel@mulgrave.site>
References: <1294254337.16957.13.camel@mulgrave.site> <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
 <1294256169.16957.18.camel@mulgrave.site>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jan 2011 11:49:12 -0800
Message-ID: <AANLkTik214sj_wBJXhJMLRie34moG7ET1Xg62oQXsgxb@mail.gmail.com>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        =?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2011/1/5 James Bottomley <James.Bottomley@hansenpartnership.com>:
>>
>> No, we really can't do that. Most of the time, the kmap() is the only
>> way we access the page anyway, so flushing things would just be
>> stupid. Why waste time and energy on doing something pointless?
>
> It's hardly pointless.  The kmap sets up an inequivalent alias in the
> cache.

NO IT DOES NOT.

Stop arguing, when you are so wrong.

kmap() does not create any aliases. For low-memory, it just returns
the physical address. No alias. And for high memory, there is no
equivalent low memory address to alias _with_.

Now, when you actually mix multiple kmap's and you have a virtually
based cache, then the kmap's obviously need to flush that particular
page when switching between each other. But that has nothing to do
with the actual page being kmap'ed, it's entirely an internal issue
about the particular virtual memory area being re-used. And ARM (and
any other virtually based CPU) already does that in __kunmap_atomic().

But notice the case of the low-mem. And understand that you are WRONG
about the "inequivalent alias" thing.

So I repeat: this has absolutely *NOTHING* to do with kmap(). Stop blathering.

It's _purely_ an issue of vm_map_ram(). Nothing else.

                          Linus

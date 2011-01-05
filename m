Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45521 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752398Ab1AETSi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 14:18:38 -0500
In-Reply-To: <1294254337.16957.13.camel@mulgrave.site>
References: <1294254337.16957.13.camel@mulgrave.site>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jan 2011 11:18:14 -0800
Message-ID: <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
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

On Wed, Jan 5, 2011 at 11:05 AM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
>
> I think the solution for the kernel direct mapping problem is to take
> the expected flushes and invalidates into kmap/kunmap[_atomic].

No, we really can't do that. Most of the time, the kmap() is the only
way we access the page anyway, so flushing things would just be
stupid. Why waste time and energy on doing something pointless?

In fact, kmap() here is a total non-issue. It's not the kmap() that
introduces any virtual aliases, and never has been. It's the
"vm_map_ram()" that is the problem. Unlike the kmap(), that really
_does_ introduce a virtual alias, and is a problem for any virtual
cache.

So don't blame kmap(). It's innocent and irrelevant - the bug could
happen entirely without it (think a 64-bit address space that doesn't
even _have_ kmap, but has software that mixes vm_map_ram() with
non-mapped accesses).

                           Linus

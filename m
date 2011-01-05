Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56528 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751360Ab1AEVJN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 16:09:13 -0500
In-Reply-To: <20110105210448.GM8638@n2100.arm.linux.org.uk>
References: <1294254337.16957.13.camel@mulgrave.site> <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
 <1294256169.16957.18.camel@mulgrave.site> <20110105200008.GJ8638@n2100.arm.linux.org.uk>
 <1294259637.16957.25.camel@mulgrave.site> <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
 <20110105210448.GM8638@n2100.arm.linux.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jan 2011 13:08:48 -0800
Message-ID: <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>,
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

On Wed, Jan 5, 2011 at 1:04 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Wed, Jan 05, 2011 at 12:48:32PM -0800, Linus Torvalds wrote:
>> (You can also force the problem with vmalloc() an then following the
>> kernel page tables, but I hope nobody does that any more. I suspect
>> I'm wrong, though, there's probably code that mixes vmalloc and
>> physical page accesses in various drivers)
>
> Should vmalloc_to_page() (84 users)/vmalloc_to_pfn() (17 users) be
> deprecated then? ;)

I do think that the "modern" way of doing it is
"vmap()"/"vm_map_ram()" and friends, and it should be preferred over
using vmalloc() and then looking up the pages.

But in the end, the two approaches really are equivalent, so it's not
like it really matters. So I don't think we need to deprecate things
officially, but obviously we should make people more aware of the
whole virtual alias thing that crops up whenever you use any of these
approaches.

                           Linus

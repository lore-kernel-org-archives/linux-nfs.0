Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59044 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755039Ab0L3Sv2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Dec 2010 13:51:28 -0500
In-Reply-To: <1293733460.4919.21.camel@heimdal.trondhjem.org>
References: <AANLkTi=-dNeeDjcSoznKtwcaNyw1mMXSqepFY89R2i+2@mail.gmail.com>
 <20101230171453.GA5787@pengutronix.de> <AANLkTikvZF6Q1k0rETLHUffkUT3grxAh3FoB_0vs96B8@mail.gmail.com>
 <1293733460.4919.21.camel@heimdal.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 30 Dec 2010 10:50:34 -0800
Message-ID: <AANLkTi=sO9M8m1Fpntu_YscVU4SrppKfxBf2eRZ2Dr+L@mail.gmail.com>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: =?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Chuck Lever <chuck.lever@oracle.com>, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 30, 2010 at 10:24 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> There is nothing we can do to protect ourselves against an infinite loop
> if the server (or underlying filesystem) is breaking the rules w.r.t.
> cookie generation. It should be possible to recover from all other
> situations.

Umm. Sure there is. Just make sure that you return the uncached entry
to user space, rather than loop forever.

Looping forever in kernel space is a bad idea. How about just changing
the "continue" into a "break" for the "uncached readdir returned
success".

No halting problems, no excuses. There is absolutely _no_ excuse for
an endless loop in kernel mode. Certainly not "the other end is
incompetent".

EVERYBODY is incompetent sometimes. That just means that you must
never trust the other end too much. You can't say "we require the
server to be sane in order not to lock up".

                    Linus

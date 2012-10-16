Return-Path: linux-nfs-owner@vger.kernel.org
Received: from science.horizon.com ([71.41.210.146]:29283 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754478Ab2JPEjr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Oct 2012 00:39:47 -0400
Date: 16 Oct 2012 00:39:46 -0400
Message-ID: <20121016043946.13851.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: linux@horizon.com, Trond.Myklebust@netapp.com
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Cc: linux-nfs@vger.kernel.org, lm@bitmover.com
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA909253B3B@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Well, I'm really glad to hear that after several people spent 3-4 hours
> debugging an NFSv2-only server side problem last Friday. Please let me
> know the next time I can help deal with another fairly simple matter of
> old compatibility calls...

I didn't mean to rouse the sarcasm monster; I was, at your prompting,
investigating the effort of maintaining it myself.

Your .sig says "NFS client", I didn't see your name a lot in the fs/nfsd
directory changelogs, and I wondered, so I *asked*.

> OK, I'll bite. What is this business-critical application that you are
> running and that will only run on a machine that is incapable of running
> a mere 20-year old protocol and that must have a 30 year old protocol?

It's the firmware for an old embedded product, which I still do occasional
fixes for.  The compiler it's been developed with is a binary from
a company that's long out of business, so I'm stuck running the old
binary on the old OS.  (The product itself doesn't date back to 1990,
but the source code archives do, since the same platform was used for
earlier products.)

Yes, I *could* just port the whole thing over to GCC, but like most
embedded code, it's very sensitive to the environment, probably makes
some non-ANSI assumptions that will anger GCC's optimizer, *does* use
a different calling convention that will require fixing all the
assembly routines, and it would require a LOT of re-testing.

Since what we have now has decades of testing, and I'd rather spend my
time developing new products, keeping everything limping along has a
lot of advantages.

My most recent changes were in February 2011: an unusual combination
of commands could cause a lockup.  Before that was adding a new baud
rate a customer needed in July 2010.  There is very little effort,
but maintaining the capability is important.

I actually tried to compile git on SunOS, but things Didn't Work Well,
so what I do is do source control on the Linux NFS server, and just
use the old machine for the actual compiles.

> The fact that you are all in a huff about base64 encoded emails
> indicates that this is not something you are running on anything as
> sophisticated as a cell phone.

I didn't mean to come across as *that* peeved about the base64; it's
mostly annoying because I can't grep my mailbox, and my preferred
mailing list archive web interface (marc.info) doesn't decode them.
And it seems perverse for an MUA to encode something as base-64 that is
100% 7-bit ASCII.  If nothing else, it bloats the message size 35%.

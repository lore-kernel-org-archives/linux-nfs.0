Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:2996 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751204AbdEDG3P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 May 2017 02:29:15 -0400
Date: Thu, 4 May 2017 08:28:52 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
To: Joe Perches <joe@perches.com>
cc: Matthew Wilcox <willy@infradead.org>,
        cocci <cocci@systeme.lip6.fr>,
        Jeff Layton <jlayton@poochiereds.net>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
In-Reply-To: <1493847363.22125.27.camel@perches.com>
Message-ID: <alpine.DEB.2.20.1705040827560.3119@hadrien>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>  <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>  <1493835238.3180.7.camel@poochiereds.net>  <1493835998.22125.15.camel@perches.com>
 <20170503203824.GA31097@bombadil.infradead.org> <1493847363.22125.27.camel@perches.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="8323329-108528635-1493879332=:3119"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--8323329-108528635-1493879332=:3119
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT



On Wed, 3 May 2017, Joe Perches wrote:

> (adding Julia Lawall and cocci)
>
> On Wed, 2017-05-03 at 13:38 -0700, Matthew Wilcox wrote:
> > On Wed, May 03, 2017 at 11:26:38AM -0700, Joe Perches wrote:
> > > On Wed, 2017-05-03 at 14:13 -0400, Jeff Layton wrote:
> > > > On Wed, 2017-05-03 at 17:04 +0100, David Howells wrote:
> > > > > +		oo = kmalloc((opts->num_mnt_opts + 1) * sizeof(char *),
> > > > > +			     GFP_KERNEL);
> >
> > If we're picking nits, then this should be kcalloc in case somebody
> > passed in 2^31 in num_mnt_opts.
>
> There are likely dozens to hundreds of possible/silent
> multiplication overflow defects in the kernel, not just
> in allocations.
>
> Auditing the sources would seem labor intensive.
>
> Perhaps coccinelle could help find them.
>
> Perhaps there should be some overflow checking functions
> added to math64.h
>
> Maybe some form like:
>
> u32 u32_mul_u32_u32(u32 a, u32 b)
> {
> 	u32 res = a * b;
>
> 	WARN_ON(a != 0 && res / a != b);
>
> 	return res;
> }

Coccinelle doesn't kow about the values of variables.  It would need some
heuristics about where potentially large values can come from.

julia
--8323329-108528635-1493879332=:3119--

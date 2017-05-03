Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0019.hostedemail.com ([216.40.44.19]:45527 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751151AbdECVgK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 17:36:10 -0400
Message-ID: <1493847363.22125.27.camel@perches.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
From: Joe Perches <joe@perches.com>
To: Matthew Wilcox <willy@infradead.org>,
        Julia Lawall <julia.lawall@lip6.fr>,
        cocci <cocci@systeme.lip6.fr>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Date: Wed, 03 May 2017 14:36:03 -0700
In-Reply-To: <20170503203824.GA31097@bombadil.infradead.org>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
         <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
         <1493835238.3180.7.camel@poochiereds.net>
         <1493835998.22125.15.camel@perches.com>
         <20170503203824.GA31097@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(adding Julia Lawall and cocci)

On Wed, 2017-05-03 at 13:38 -0700, Matthew Wilcox wrote:
> On Wed, May 03, 2017 at 11:26:38AM -0700, Joe Perches wrote:
> > On Wed, 2017-05-03 at 14:13 -0400, Jeff Layton wrote:
> > > On Wed, 2017-05-03 at 17:04 +0100, David Howells wrote:
> > > > +		oo = kmalloc((opts->num_mnt_opts + 1) * sizeof(char *),
> > > > +			     GFP_KERNEL);
> 
> If we're picking nits, then this should be kcalloc in case somebody
> passed in 2^31 in num_mnt_opts.

There are likely dozens to hundreds of possible/silent
multiplication overflow defects in the kernel, not just
in allocations.

Auditing the sources would seem labor intensive.

Perhaps coccinelle could help find them.

Perhaps there should be some overflow checking functions
added to math64.h

Maybe some form like:

u32 u32_mul_u32_u32(u32 a, u32 b)
{
	u32 res = a * b;

	WARN_ON(a != 0 && res / a != b);

	return res;
}


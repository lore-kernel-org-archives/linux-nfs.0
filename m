Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59215 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753216AbaHTWTk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 18:19:40 -0400
Date: Wed, 20 Aug 2014 15:19:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trondmy@gmail.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2] NFSD: Convert magic numbers to sizeof() for
 encode/decode
Message-ID: <20140820221938.GA20442@infradead.org>
References: <53F4994A.3060506@gmail.com>
 <CAABAsM65rWByuQYrWZ8jiieMzkitdRgVA5-zxxXTqE+ddvN8AA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAABAsM65rWByuQYrWZ8jiieMzkitdRgVA5-zxxXTqE+ddvN8AA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 20, 2014 at 09:42:38AM -0400, Trond Myklebust wrote:
> OK, can someone please tell me how this is useful for documentation
> purposes? Anybody who doesn't know that sizeof(__be32) == 4 has no
> business working on XDR code.
> I could understand this kind of patch if you were converting to
> sizeof(<variable name>), as that documents exactly which variable you
> are going to encode in this buffer and so is better than a naked
> value, but how is sizeof(__be32) any more useful documentation than
> "4"?

I think this was in reply to my complaints about the very magic length
reserved.  I think arithmetic expressions in the form of 4 + 4 + 8 etc
are fine too, although the sizeof expressions seem to be even more
obvious and thus preferable to me.  The main problem is something like:


        p = xdr_reserve_space(xdr, 20);

hidden deep down in a routine which requires you to count over
all kinds of statements working with the XDR stream.


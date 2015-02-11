Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:42327 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388AbbBKOyO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Feb 2015 09:54:14 -0500
Date: Wed, 11 Feb 2015 09:54:13 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: default NFSv4.2 to on
Message-ID: <20150211145413.GC25696@fieldses.org>
References: <20150202161557.GF22301@fieldses.org>
 <20150211123757.GA10532@infradead.org>
 <20150211141257.GA25696@fieldses.org>
 <20150211141619.GA24299@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150211141619.GA24299@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 06:16:19AM -0800, Christoph Hellwig wrote:
> On Wed, Feb 11, 2015 at 09:12:57AM -0500, J. Bruce Fields wrote:
> > I think so.  That's all optional--e.g. for READ_PLUS clients can
> > determine server support using ERR_OP_NOTSUPP (or whatever it's called),
> > and for attributes they can query the supported_attributes attribute.
> > It's possible we'll never support everything in 4.2.
> 
> The questions is if we need a useful subset of 4.2 to bother.

Internally the virtualization people have been interested in ALLOCATE,
SEEK, and security labels, so I'm assuming we've passed that sort of
minimum "is there any benefit at all to turning this on" threshhold.

> I doubt we'll ever bother with ADBs for example, and the copy offload
> might take a while to get everyting sorted.  But exposting most
> attributes and supporting READ_PLUS sounds like important enought to
> implement before considering 4.2 ready.

I agree there's a documentation and marketing problem: it would simplify
communication with users if "this server supports 4.2" reliably meant
support for some minimum list of features.  Is that what you're thinking
about?

Individual distros and other server vendors may make their own decisions
here, so I don't know if we do much about that on our own.

We could also add a little more data e.g. to /proc/self/mountstats to
help figure out stuff like "why does copying a big file go so much
faster on server X than server Y?".

--b.

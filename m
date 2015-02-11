Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:42315 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752002AbbBKOM6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Feb 2015 09:12:58 -0500
Date: Wed, 11 Feb 2015 09:12:57 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: default NFSv4.2 to on
Message-ID: <20150211141257.GA25696@fieldses.org>
References: <20150202161557.GF22301@fieldses.org>
 <20150211123757.GA10532@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150211123757.GA10532@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 04:37:57AM -0800, Christoph Hellwig wrote:
> On Mon, Feb 02, 2015 at 11:15:57AM -0500, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > The code seems to work.  The protocol looks stable.  The kernel's
> > version defaults can be overridden by rpc.nfsd arguments.
> 
> Does it really make sense to enabled this without READ_PLUS support
> or implementing the various new attributes?

I think so.  That's all optional--e.g. for READ_PLUS clients can
determine server support using ERR_OP_NOTSUPP (or whatever it's called),
and for attributes they can query the supported_attributes attribute.
It's possible we'll never support everything in 4.2.

> Also should we add a wiki page with the 4.2 status?

Sounds like a good idea.

--b.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45432 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807Ab3KDTzi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 14:55:38 -0500
Date: Mon, 4 Nov 2013 14:55:33 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131104195533.GD5358@fieldses.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131102135238.GB18961@infradead.org>
 <5277CE23.6010207@netapp.com>
 <20131104170345.GA31499@infradead.org>
 <5277D80F.8050106@netapp.com>
 <20131104185309.GA14378@infradead.org>
 <3AC4ECC6-0496-4593-8791-92BCAD2567CC@oracle.com>
 <20131104191907.GA9337@infradead.org>
 <8EB0049A-9225-4C4A-8099-774B2EB48323@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8EB0049A-9225-4C4A-8099-774B2EB48323@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 04, 2013 at 11:50:51AM -0800, Chuck Lever wrote:
> 
> On Nov 4, 2013, at 11:19 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Mon, Nov 04, 2013 at 11:16:13AM -0800, Chuck Lever wrote:
> >>> I still don't understand why anyone would phase out WRITE in favour of
> >>> something that doesn't actually add any value for the write case.
> >> 
> >> Protocol extensibility.  WRITE_PLUS adds a discriminated union of data types that can be extended easily to include initialization patterns, integrity metadata, and other things like holes.  It's entirely another question as to whether any particular extension is tasteful.
> > 
> > Maybe I'm missing something, but what does multiplexing entirely
> > different operation actually buy you?  It is different operation after
> > all.
> 
> I think a successful argument could be made that initialization or hole punching may not belong in a WRITE_PLUS operation.  For example, using a COMMIT for a long-running server-performed file initialization doesn't make sense to me.  The infrastructure we introduced for COPY_OFFLOAD seems better suited for file initialization.
> 
> > It's not like adding new operations to NFS is all that hard.
> 
> Actually, it is harder than you think.  For various reasons, it takes five or more years to create a new NFS protocol specification, something we hope to address.

Well, but that's not really a function of the number of operations.
It's not as though implementing hole punching will take more or less
time depending on whether we implement something as a compound op or a
union.

--b.

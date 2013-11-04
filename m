Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:40097 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497Ab3KDTTJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 14:19:09 -0500
Date: Mon, 4 Nov 2013 11:19:07 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <bjschuma@netapp.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131104191907.GA9337@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131102135238.GB18961@infradead.org>
 <5277CE23.6010207@netapp.com>
 <20131104170345.GA31499@infradead.org>
 <5277D80F.8050106@netapp.com>
 <20131104185309.GA14378@infradead.org>
 <3AC4ECC6-0496-4593-8791-92BCAD2567CC@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3AC4ECC6-0496-4593-8791-92BCAD2567CC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 04, 2013 at 11:16:13AM -0800, Chuck Lever wrote:
> > I still don't understand why anyone would phase out WRITE in favour of
> > something that doesn't actually add any value for the write case.
> 
> Protocol extensibility.  WRITE_PLUS adds a discriminated union of data types that can be extended easily to include initialization patterns, integrity metadata, and other things like holes.  It's entirely another question as to whether any particular extension is tasteful.

Maybe I'm missing something, but what does multiplexing entirely
different operation actually buy you?  It is different operation after
all.  It's not like adding new operations to NFS is all that hard.

> The mailing list is not the only place where they are discussed.  We also use conference calls, and there are face-to-face meetings too.  Not all of that content is distilled into a public record.  Very much like Linux kernel development.

Linux development strives very hard documenting rationales, something I
haven't found on the NFS list or in the repository.


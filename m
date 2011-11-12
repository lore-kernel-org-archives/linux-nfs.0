Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:49138
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751874Ab1KLOuA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2011 09:50:00 -0500
Date: Sat, 12 Nov 2011 09:49:53 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Matthew Treinish <treinish@linux.vnet.ibm.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20111112144953.GA3740@infradead.org>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
 <1321056809.8733.2.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321056809.8733.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 11, 2011 at 07:13:29PM -0500, Trond Myklebust wrote:
> On Fri, 2011-11-11 at 18:04 -0500, Matthew Treinish wrote: 
> > This patch series implements client side support for volatile file handle
> > recovery (RFC 3530 section 4.2 and 4.3) with walk back using the dcache. To
> > test the client you either need a server that supports volatile file handles or 
> > you can hard code the server to output NFS4ERR_FHEXPIRED instead of
> > NFSERR_STALE. (See the last patch in the series)
> 
> WHY do we want to support this kind of "feature"? As you said, the RFC
> doesn't actually help in figuring out how this crap is supposed to work
> in practice, so why do we even consider starting to give a damn?

*nod*. Pretending we handle it seems fairly dangerous.  I'd much prefer
outright rejecting it.

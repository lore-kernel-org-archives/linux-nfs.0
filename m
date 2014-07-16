Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35485 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbaGPINe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 04:13:34 -0400
Date: Wed, 16 Jul 2014 01:13:32 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, trond.myklebust@primarydata.com,
        bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/7] sunrpc: clean up sparse endianness warnings in
 gss_krb5_wrap.c
Message-ID: <20140716081332.GD29924@infradead.org>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
 <1405303064-9102-7-git-send-email-jlayton@primarydata.com>
 <20140715170442.GC7767@infradead.org>
 <20140715133614.38361d58@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140715133614.38361d58@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2014 at 01:36:14PM -0400, Jeff Layton wrote:
> > >  
> > > +	*(__be16 *)(ptr + 2) = (__force __be16)cpu_to_le16(kctx->gk5e->signalg);
> > 
> > This looks silly.  This should be:
> > 
> > 	*(__le16 *)(ptr + 2) = cpu_to_le16(kctx->gk5e->signalg);
> > 
> > Maybe with a comment somewhere explaining why we're doing little endian
> > encoding here if it's not obvious from the surrounding code.
> > 
> 
> The spec doesn't really define these as little-endian values, it's just
> an opaque series of bytes that the kernel implementation happens to
> handle as little-endian (see RFC 1964, section 1.2.1). Maybe I should
> reverse the bytes and we can just make that cpu_to_be16 instead?

Sounds okay to me.

> So the code is correct, AFAICT -- it's just odd...

It might be correct, but with the added cast it's simply too ugly to
live.


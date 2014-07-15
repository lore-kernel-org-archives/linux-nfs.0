Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:63566 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbaGORcW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:32:22 -0400
Received: by mail-qc0-f177.google.com with SMTP id o8so5039978qcw.36
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 10:32:22 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 15 Jul 2014 13:32:20 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/7] sunrpc: clean up endianness warnings in setup_token
Message-ID: <20140715133220.3f02aec0@tlielax.poochiereds.net>
In-Reply-To: <20140715170806.GE7767@infradead.org>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
	<1405303064-9102-4-git-send-email-jlayton@primarydata.com>
	<20140715170806.GE7767@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 15 Jul 2014 10:08:06 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Sun, Jul 13, 2014 at 09:57:40PM -0400, Jeff Layton wrote:
> > This is safe since KG_TOK_MIC_MSG and SEAL_ALG_NONE are both endian
> > palindromes. I'm also making the assumption that the signalg field
> > really should be in little-endian. That looks odd, but looking at the
> > spec I guess it's correct.
> 
> > @@ -83,10 +83,10 @@ setup_token(struct krb5_ctx *ctx, struct xdr_netobj *token)
> >  
> >  	/* ptr now at start of header described in rfc 1964, section 1.2.1: */
> >  	krb5_hdr = ptr;
> > +	*ptr++ = cpu_to_be16(KG_TOK_MIC_MSG);
> > +	*ptr++ = (__force __be16)cpu_to_le16(ctx->gk5e->signalg);
> > +	*ptr++ = cpu_to_be16(SEAL_ALG_NONE);
> > +	*ptr++ = cpu_to_be16(0xffff);
> 
> If signalg is little endian and all others are palindromes it seems
> like ptr should be defines as __le16.
> 

The spec doesn't really define it as little-endian. It's just an opaque series of bytes that happens to be a little-endian representation of 


> >  	return (char *)krb5_hdr;
> 
> Seems like krb5_hdr should simply be defined as void *, together with
> the return value?
> 

Yeah, that may make more sense.

-- 
Jeff Layton <jlayton@primarydata.com>

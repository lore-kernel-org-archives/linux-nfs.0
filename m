Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:51293 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755445AbaGORgQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:36:16 -0400
Received: by mail-qc0-f177.google.com with SMTP id o8so5045530qcw.36
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 10:36:16 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 15 Jul 2014 13:36:14 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/7] sunrpc: clean up sparse endianness warnings in
 gss_krb5_wrap.c
Message-ID: <20140715133614.38361d58@tlielax.poochiereds.net>
In-Reply-To: <20140715170442.GC7767@infradead.org>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
	<1405303064-9102-7-git-send-email-jlayton@primarydata.com>
	<20140715170442.GC7767@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 15 Jul 2014 10:04:42 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Sun, Jul 13, 2014 at 09:57:43PM -0400, Jeff Layton wrote:
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  net/sunrpc/auth_gss/gss_krb5_wrap.c | 10 +++++-----
> >  1 file changed, 5 insertions(+), 5 deletions(-)
> > 
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > index 42560e55d978..c5cc0270a334 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > @@ -201,9 +201,9 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
> >  
> >  	msg_start = ptr + GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength;
> >  
> > +	*(__be16 *)(ptr + 2) = (__force __be16)cpu_to_le16(kctx->gk5e->signalg);
> 
> This looks silly.  This should be:
> 
> 	*(__le16 *)(ptr + 2) = cpu_to_le16(kctx->gk5e->signalg);
> 
> Maybe with a comment somewhere explaining why we're doing little endian
> encoding here if it's not obvious from the surrounding code.
> 

The spec doesn't really define these as little-endian values, it's just
an opaque series of bytes that the kernel implementation happens to
handle as little-endian (see RFC 1964, section 1.2.1). Maybe I should
reverse the bytes and we can just make that cpu_to_be16 instead?

So the code is correct, AFAICT -- it's just odd...

-- 
Jeff Layton <jlayton@primarydata.com>

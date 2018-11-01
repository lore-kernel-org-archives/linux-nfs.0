Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42175C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 13:18:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E1FA3204FD
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 13:18:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1FA3204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728282AbeKAWVt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 18:21:49 -0400
Received: from foss.arm.com ([217.140.101.70]:56414 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727644AbeKAWVt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Nov 2018 18:21:49 -0400
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AB75EA78;
        Thu,  1 Nov 2018 06:18:52 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 073A63F6A8;
        Thu,  1 Nov 2018 06:18:48 -0700 (PDT)
Date:   Thu, 1 Nov 2018 13:18:46 +0000
From:   Mark Rutland <mark.rutland@arm.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux@roeck-us.net" <linux@roeck-us.net>,
        "paul.burton@mips.com" <paul.burton@mips.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ralf@linux-mips.org" <ralf@linux-mips.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jhogan@kernel.org" <jhogan@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "arnd@arndb.de" <arnd@arndb.de>,
        "paulus@samba.org" <paulus@samba.org>,
        "mpe@ellerman.id.au" <mpe@ellerman.id.au>,
        "benh@kernel.crashing.org" <benh@kernel.crashing.org>,
        Will Deacon <will.deacon@arm.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Message-ID: <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
References: <1541015538-11382-1-git-send-email-linux@roeck-us.net>
 <20181031213240.zhh7dfcm47ucuyfl@pburton-laptop>
 <20181031220253.GA15505@roeck-us.net>
 <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
 <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
User-Agent: NeoMutt/20170113 (1.7.2)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

[adding the atomic maintainers]

On Thu, Nov 01, 2018 at 12:17:31AM +0000, Trond Myklebust wrote:
> On Wed, 2018-10-31 at 23:32 +0000, Paul Burton wrote:
> > (Copying SunRPC & net maintainers.)
> > 
> > Hi Guenter,
> > 
> > On Wed, Oct 31, 2018 at 03:02:53PM -0700, Guenter Roeck wrote:
> > > The alternatives I can see are
> > > - Do not use cmpxchg64() outside architecture code (ie drop its use
> > > from the offending driver, and keep doing the same whenever the
> > > problem comes up again).
> > > or
> > > - Introduce something like ARCH_HAS_CMPXCHG64 and use it to
> > > determine if cmpxchg64 is supported or not.
> > > 
> > > Any preference ?
> > 
> > My preference would be option 1 - avoiding cmpxchg64() where
> > possible in generic code. I wouldn't be opposed to the Kconfig
> > option if there are cases where cmpxchg64() can really help
> > performance though.
> > 
> > The last time I'm aware of this coming up the affected driver was
> > modified to avoid cmpxchg64() [1].
> > 
> > In this particular case I have no idea why
> > net/sunrpc/auth_gss/gss_krb5_seal.c is using cmpxchg64() at all.
> > It's essentially reinventing atomic64_fetch_inc() which is already
> > provided everywhere via CONFIG_GENERIC_ATOMIC64 & the spinlock
> > approach. At least for atomic64_* functions the assumption that all
> > access will be performed using those same functions seems somewhat
> > reasonable.
> > 
> > So how does the below look? Trond?
> 
> My one question (and the reason why I went with cmpxchg() in the first
> place) would be about the overflow behaviour for atomic_fetch_inc() and
> friends. I believe those functions should be OK on x86, so that when we
> overflow the counter, it behaves like an unsigned value and wraps back
> around.  Is that the case for all architectures?
> 
> i.e. are atomic_t/atomic64_t always guaranteed to behave like u32/u64
> on increment?
> 
> I could not find any documentation that explicitly stated that they
> should.

Peter, Will, I understand that the atomic_t/atomic64_t ops are required
to wrap per 2's-complement. IIUC the refcount code relies on this.

Can you confirm?

Thanks,
Mark.

> Cheers
>   Trond
> 
> > Thanks,
> >     Paul
> > 
> > [1] https://patchwork.ozlabs.org/cover/891284/
> > 
> > ---
> > diff --git a/include/linux/sunrpc/gss_krb5.h
> > b/include/linux/sunrpc/gss_krb5.h
> > index 131424cefc6a..02c0412e368c 100644
> > --- a/include/linux/sunrpc/gss_krb5.h
> > +++ b/include/linux/sunrpc/gss_krb5.h
> > @@ -107,8 +107,8 @@ struct krb5_ctx {
> >  	u8			Ksess[GSS_KRB5_MAX_KEYLEN]; /*
> > session key */
> >  	u8			cksum[GSS_KRB5_MAX_KEYLEN];
> >  	s32			endtime;
> > -	u32			seq_send;
> > -	u64			seq_send64;
> > +	atomic_t		seq_send;
> > +	atomic64_t		seq_send64;
> >  	struct xdr_netobj	mech_used;
> >  	u8			initiator_sign[GSS_KRB5_MAX_KEYLEN];
> >  	u8			acceptor_sign[GSS_KRB5_MAX_KEYLEN];
> > @@ -118,9 +118,6 @@ struct krb5_ctx {
> >  	u8			acceptor_integ[GSS_KRB5_MAX_KEYLEN];
> >  };
> >  
> > -extern u32 gss_seq_send_fetch_and_inc(struct krb5_ctx *ctx);
> > -extern u64 gss_seq_send64_fetch_and_inc(struct krb5_ctx *ctx);
> > -
> >  /* The length of the Kerberos GSS token header */
> >  #define GSS_KRB5_TOK_HDR_LEN	(16)
> >  
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c
> > b/net/sunrpc/auth_gss/gss_krb5_mech.c
> > index 7f0424dfa8f6..eab71fc7af3e 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
> > @@ -274,6 +274,7 @@ get_key(const void *p, const void *end,
> >  static int
> >  gss_import_v1_context(const void *p, const void *end, struct
> > krb5_ctx *ctx)
> >  {
> > +	u32 seq_send;
> >  	int tmp;
> >  
> >  	p = simple_get_bytes(p, end, &ctx->initiate, sizeof(ctx-
> > >initiate));
> > @@ -315,9 +316,10 @@ gss_import_v1_context(const void *p, const void
> > *end, struct krb5_ctx *ctx)
> >  	p = simple_get_bytes(p, end, &ctx->endtime, sizeof(ctx-
> > >endtime));
> >  	if (IS_ERR(p))
> >  		goto out_err;
> > -	p = simple_get_bytes(p, end, &ctx->seq_send, sizeof(ctx-
> > >seq_send));
> > +	p = simple_get_bytes(p, end, &seq_send, sizeof(seq_send));
> >  	if (IS_ERR(p))
> >  		goto out_err;
> > +	atomic_set(&ctx->seq_send, seq_send);
> >  	p = simple_get_netobj(p, end, &ctx->mech_used);
> >  	if (IS_ERR(p))
> >  		goto out_err;
> > @@ -607,6 +609,7 @@ static int
> >  gss_import_v2_context(const void *p, const void *end, struct
> > krb5_ctx *ctx,
> >  		gfp_t gfp_mask)
> >  {
> > +	u64 seq_send64;
> >  	int keylen;
> >  
> >  	p = simple_get_bytes(p, end, &ctx->flags, sizeof(ctx->flags));
> > @@ -617,14 +620,15 @@ gss_import_v2_context(const void *p, const void
> > *end, struct krb5_ctx *ctx,
> >  	p = simple_get_bytes(p, end, &ctx->endtime, sizeof(ctx-
> > >endtime));
> >  	if (IS_ERR(p))
> >  		goto out_err;
> > -	p = simple_get_bytes(p, end, &ctx->seq_send64, sizeof(ctx-
> > >seq_send64));
> > +	p = simple_get_bytes(p, end, &seq_send64, sizeof(seq_send64));
> >  	if (IS_ERR(p))
> >  		goto out_err;
> > +	atomic64_set(&ctx->seq_send64, seq_send64);
> >  	/* set seq_send for use by "older" enctypes */
> > -	ctx->seq_send = ctx->seq_send64;
> > -	if (ctx->seq_send64 != ctx->seq_send) {
> > -		dprintk("%s: seq_send64 %lx, seq_send %x overflow?\n",
> > __func__,
> > -			(unsigned long)ctx->seq_send64, ctx->seq_send);
> > +	atomic_set(&ctx->seq_send, seq_send64);
> > +	if (seq_send64 != atomic_read(&ctx->seq_send)) {
> > +		dprintk("%s: seq_send64 %llx, seq_send %x overflow?\n",
> > __func__,
> > +			seq_send64, atomic_read(&ctx->seq_send));
> >  		p = ERR_PTR(-EINVAL);
> >  		goto out_err;
> >  	}
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c
> > b/net/sunrpc/auth_gss/gss_krb5_seal.c
> > index b4adeb06660b..48fe4a591b54 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_seal.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
> > @@ -123,30 +123,6 @@ setup_token_v2(struct krb5_ctx *ctx, struct
> > xdr_netobj *token)
> >  	return krb5_hdr;
> >  }
> >  
> > -u32
> > -gss_seq_send_fetch_and_inc(struct krb5_ctx *ctx)
> > -{
> > -	u32 old, seq_send = READ_ONCE(ctx->seq_send);
> > -
> > -	do {
> > -		old = seq_send;
> > -		seq_send = cmpxchg(&ctx->seq_send, old, old + 1);
> > -	} while (old != seq_send);
> > -	return seq_send;
> > -}
> > -
> > -u64
> > -gss_seq_send64_fetch_and_inc(struct krb5_ctx *ctx)
> > -{
> > -	u64 old, seq_send = READ_ONCE(ctx->seq_send);
> > -
> > -	do {
> > -		old = seq_send;
> > -		seq_send = cmpxchg64(&ctx->seq_send64, old, old + 1);
> > -	} while (old != seq_send);
> > -	return seq_send;
> > -}
> > -
> >  static u32
> >  gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
> >  		struct xdr_netobj *token)
> > @@ -177,7 +153,7 @@ gss_get_mic_v1(struct krb5_ctx *ctx, struct
> > xdr_buf *text,
> >  
> >  	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data,
> > md5cksum.len);
> >  
> > -	seq_send = gss_seq_send_fetch_and_inc(ctx);
> > +	seq_send = atomic_fetch_inc(&ctx->seq_send);
> >  
> >  	if (krb5_make_seq_num(ctx, ctx->seq, ctx->initiate ? 0 : 0xff,
> >  			      seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr
> > + 8))
> > @@ -205,7 +181,7 @@ gss_get_mic_v2(struct krb5_ctx *ctx, struct
> > xdr_buf *text,
> >  
> >  	/* Set up the sequence number. Now 64-bits in clear
> >  	 * text and w/o direction indicator */
> > -	seq_send_be64 = cpu_to_be64(gss_seq_send64_fetch_and_inc(ctx));
> > +	seq_send_be64 = cpu_to_be64(atomic64_fetch_inc(&ctx-
> > >seq_send64));
> >  	memcpy(krb5_hdr + 8, (char *) &seq_send_be64, 8);
> >  
> >  	if (ctx->initiate) {
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > index 962fa84e6db1..5cdde6cb703a 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > @@ -228,7 +228,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int
> > offset,
> >  
> >  	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data,
> > md5cksum.len);
> >  
> > -	seq_send = gss_seq_send_fetch_and_inc(kctx);
> > +	seq_send = atomic_fetch_inc(&kctx->seq_send);
> >  
> >  	/* XXX would probably be more efficient to compute checksum
> >  	 * and encrypt at the same time: */
> > @@ -475,7 +475,7 @@ gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32
> > offset,
> >  	*be16ptr++ = 0;
> >  
> >  	be64ptr = (__be64 *)be16ptr;
> > -	*be64ptr = cpu_to_be64(gss_seq_send64_fetch_and_inc(kctx));
> > +	*be64ptr = cpu_to_be64(atomic64_fetch_inc(&kctx->seq_send64));
> >  
> >  	err = (*kctx->gk5e->encrypt_v2)(kctx, offset, buf, pages);
> >  	if (err)
> -- 
> Trond Myklebust
> CTO, Hammerspace Inc
> 4300 El Camino Real, Suite 105
> Los Altos, CA 94022
> www.hammer.space
> 
> 

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:60511 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755430AbaG3R4g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 13:56:36 -0400
Received: by mail-qg0-f51.google.com with SMTP id a108so2231100qge.10
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 10:56:35 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 30 Jul 2014 13:56:33 -0400
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] sunrpc: sparse warning cleanups
Message-ID: <20140730135633.1318ef1e@tlielax.poochiereds.net>
In-Reply-To: <1405507942-12256-1-git-send-email-jlayton@primarydata.com>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
	<1405507942-12256-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Jul 2014 06:52:17 -0400
Jeff Layton <jlayton@primarydata.com> wrote:

> v2:
> - reworked the gss_krb5_seal.c and gss_krb5_wrap.c patches to be less
>   ugly
> - squashed the setup_token patch into the gss_krb5_seal.c patch
> - dropped patch to make xdr_get_next_encode_buffer static since Trond
>   proposed the same fix
> 
> This fixes up all of the sparse warnings that I see when building
> net/sunrpc. The only real substantive change is the second patch which
> should fix the RCU handling for the gc_ctx field. That looks quite wrong
> right now, though it may be that the refcounting and lifecycle of the
> thing helps paper over it today.
> 
> There are still a few warnings that come from generic ipv6.h inlines.
> I'll send a separate patch to the netdev folks to address those.
> 
> Trond, if these look OK then they should probably go via your tree as it
> looks like you've already merged the gc_acceptor patches and the RCU
> fixes in patch #2 should apply on top of those.
> 
> Jeff Layton (5):
>   sunrpc: remove __rcu annotation from struct gss_cl_ctx->gc_gss_ctx
>   sunrpc: fix RCU handling of gc_ctx field
>   sunrpc: clean up sparse endianness warnings in gss_krb5_seal.c
>   sunrpc: clean up sparse endianness warnings in gss_krb5_wrap.c
>   sunrpc: remove "ec" argument from encrypt_v2 operation
> 
>  include/linux/sunrpc/auth_gss.h       |  2 +-
>  include/linux/sunrpc/gss_krb5.h       |  4 +--
>  net/sunrpc/auth_gss/auth_gss.c        | 52 +++++++++++++++++++++++------------
>  net/sunrpc/auth_gss/gss_krb5_crypto.c |  9 ++----
>  net/sunrpc/auth_gss/gss_krb5_seal.c   | 28 +++++++++++--------
>  net/sunrpc/auth_gss/gss_krb5_wrap.c   | 20 +++++++++-----
>  6 files changed, 70 insertions(+), 45 deletions(-)
> 

Trond, I noticed that you hadn't yet picked these patches up into your
tree. I'd like to get these in since they do make it easier to spot
real bugs with sparse. Are these better fed via your or Bruce's tree?

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>

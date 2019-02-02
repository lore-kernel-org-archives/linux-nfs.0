Return-Path: <SRS0=aDhS=QJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78594C282D8
	for <linux-nfs@archiver.kernel.org>; Sat,  2 Feb 2019 02:30:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 53F2820869
	for <linux-nfs@archiver.kernel.org>; Sat,  2 Feb 2019 02:30:42 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726516AbfBBCal (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Feb 2019 21:30:41 -0500
Received: from p3plsmtpa11-04.prod.phx3.secureserver.net ([68.178.252.105]:35538
        "EHLO p3plsmtpa11-04.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726067AbfBBCal (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Feb 2019 21:30:41 -0500
Received: from [192.168.0.55] ([24.218.182.144])
        by :SMTPAUTH: with ESMTPSA
        id pl4qgIR9qZBM2pl4qgiLi2; Fri, 01 Feb 2019 19:30:40 -0700
Subject: Re: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
To:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Cc:     simo@redhat.com
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195747.11389.75164.stgit@manet.1015granger.net>
From:   Tom Talpey <tom@talpey.com>
Message-ID: <7a88add8-c1a3-72b5-cdcc-e6e7578e2ccc@talpey.com>
Date:   Fri, 1 Feb 2019 21:30:40 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190201195747.11389.75164.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfPbuoKMbJjWIASx8e/8qiRE6bQwgLNxoCyvQIklnKmHkMCX2XS5s4lf+wTNxwYb+PMdiFPQ776o+YA+OXXTBBbeN3qajVBq9QzCoyER/QR6i1IWwr8RL
 nGs4eaB3txxy4pmJUznCFEZfsn3lczi0xunxWA1/HqIfZMDNcbPEIzMPSXe8U8XrmOSBmU/HKsQHOjPo+oc9yVCRVIMKAUjPyQZlVROaIAqHCc0VOJDBlpMf
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2/1/2019 2:57 PM, Chuck Lever wrote:
> Byte-swapping causes a CPU pipeline bubble on some processors. When
> a decoder is comparing an on-the-wire value for equality, byte-
> swapping can be avoided by comparing it directly to a pre-byte-
> swapped constant value.
> 
> The current set of pre-xdr'd constants is missing some common values
> used in the RPC header. Fill those out.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   include/linux/sunrpc/auth_gss.h |    5 ++-
>   include/linux/sunrpc/xdr.h      |   66 ++++++++++++++++++++++++---------------
>   2 files changed, 45 insertions(+), 26 deletions(-)
> 
> diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
> index 30427b7..adc4be2 100644
> --- a/include/linux/sunrpc/auth_gss.h
> +++ b/include/linux/sunrpc/auth_gss.h
> @@ -19,7 +19,10 @@
>   #include <linux/sunrpc/svc.h>
>   #include <linux/sunrpc/gss_api.h>
>   
> -#define RPC_GSS_VERSION		1
> +enum {
> +	RPC_GSS_VERSION = 1,
> +	rpc_gss_version = cpu_to_be32(RPC_GSS_VERSION)
> +};
>   
>   #define MAXSEQ 0x80000000 /* maximum legal sequence number, from rfc 2203 */
>   
> diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
> index 787939d..69161cb 100644
> --- a/include/linux/sunrpc/xdr.h
> +++ b/include/linux/sunrpc/xdr.h
> @@ -17,6 +17,7 @@
>   #include <asm/byteorder.h>
>   #include <asm/unaligned.h>
>   #include <linux/scatterlist.h>
> +#include <linux/sunrpc/msg_prot.h>
>   
>   struct bio_vec;
>   struct rpc_rqst;
> @@ -79,31 +80,46 @@ struct xdr_buf {
>   	buf->buflen = len;
>   }
>   
> -/*
> - * pre-xdr'ed macros.
> - */
> -
> -#define	xdr_zero	cpu_to_be32(0)
> -#define	xdr_one		cpu_to_be32(1)
> -#define	xdr_two		cpu_to_be32(2)
> -
> -#define	rpc_success		cpu_to_be32(RPC_SUCCESS)
> -#define	rpc_prog_unavail	cpu_to_be32(RPC_PROG_UNAVAIL)
> -#define	rpc_prog_mismatch	cpu_to_be32(RPC_PROG_MISMATCH)
> -#define	rpc_proc_unavail	cpu_to_be32(RPC_PROC_UNAVAIL)
> -#define	rpc_garbage_args	cpu_to_be32(RPC_GARBAGE_ARGS)
> -#define	rpc_system_err		cpu_to_be32(RPC_SYSTEM_ERR)
> -#define	rpc_drop_reply		cpu_to_be32(RPC_DROP_REPLY)
> -
> -#define	rpc_auth_ok		cpu_to_be32(RPC_AUTH_OK)
> -#define	rpc_autherr_badcred	cpu_to_be32(RPC_AUTH_BADCRED)
> -#define	rpc_autherr_rejectedcred cpu_to_be32(RPC_AUTH_REJECTEDCRED)
> -#define	rpc_autherr_badverf	cpu_to_be32(RPC_AUTH_BADVERF)
> -#define	rpc_autherr_rejectedverf cpu_to_be32(RPC_AUTH_REJECTEDVERF)
> -#define	rpc_autherr_tooweak	cpu_to_be32(RPC_AUTH_TOOWEAK)
> -#define	rpcsec_gsserr_credproblem	cpu_to_be32(RPCSEC_GSS_CREDPROBLEM)
> -#define	rpcsec_gsserr_ctxproblem	cpu_to_be32(RPCSEC_GSS_CTXPROBLEM)
> -#define	rpc_autherr_oldseqnum	cpu_to_be32(101)
> +enum xdr_be32_equivalents {
> +	xdr_zero		= cpu_to_be32(0),
> +	xdr_one			= cpu_to_be32(1),
> +	xdr_two			= cpu_to_be32(2),

It is clever to use an enum to pre-compute these values, but
it becomes a concern that the type (and size) of an enum may
not be the same as values they may be compared to.

Commonly, code may compare them to int32, uint32, etc. What
guarantees are there that such comparisons will yield the
appropriate result, especially if a < or > test is performed?

Tom.

> +
> +	rpc_version		= cpu_to_be32(RPC_VERSION),
> +
> +	rpc_auth_null		= cpu_to_be32(RPC_AUTH_NULL),
> +	rpc_auth_unix		= cpu_to_be32(RPC_AUTH_UNIX),
> +	rpc_auth_short		= cpu_to_be32(RPC_AUTH_SHORT),
> +	rpc_auth_des		= cpu_to_be32(RPC_AUTH_DES),
> +	rpc_auth_krb		= cpu_to_be32(RPC_AUTH_KRB),
> +	rpc_auth_gss		= cpu_to_be32(RPC_AUTH_GSS),
> +
> +	rpc_call		= cpu_to_be32(RPC_CALL),
> +	rpc_reply		= cpu_to_be32(RPC_REPLY),
> +
> +	rpc_msg_accepted	= cpu_to_be32(RPC_MSG_ACCEPTED),
> +	rpc_msg_denied		= cpu_to_be32(RPC_MSG_DENIED),
> +
> +	rpc_success		= cpu_to_be32(RPC_SUCCESS),
> +	rpc_prog_unavail	= cpu_to_be32(RPC_PROG_UNAVAIL),
> +	rpc_prog_mismatch	= cpu_to_be32(RPC_PROG_MISMATCH),
> +	rpc_proc_unavail	= cpu_to_be32(RPC_PROC_UNAVAIL),
> +	rpc_garbage_args	= cpu_to_be32(RPC_GARBAGE_ARGS),
> +	rpc_system_err		= cpu_to_be32(RPC_SYSTEM_ERR),
> +	rpc_drop_reply		= cpu_to_be32(RPC_DROP_REPLY),
> +
> +	rpc_mismatch		= cpu_to_be32(RPC_MISMATCH),
> +	rpc_auth_error		= cpu_to_be32(RPC_AUTH_ERROR),
> +
> +	rpc_auth_ok		= cpu_to_be32(RPC_AUTH_OK),
> +	rpc_autherr_badcred	= cpu_to_be32(RPC_AUTH_BADCRED),
> +	rpc_autherr_rejectedcred = cpu_to_be32(RPC_AUTH_REJECTEDCRED),
> +	rpc_autherr_badverf	= cpu_to_be32(RPC_AUTH_BADVERF),
> +	rpc_autherr_rejectedverf = cpu_to_be32(RPC_AUTH_REJECTEDVERF),
> +	rpc_autherr_tooweak	= cpu_to_be32(RPC_AUTH_TOOWEAK),
> +	rpcsec_gsserr_credproblem = cpu_to_be32(RPCSEC_GSS_CREDPROBLEM),
> +	rpcsec_gsserr_ctxproblem = cpu_to_be32(RPCSEC_GSS_CTXPROBLEM),
> +};
>   
>   /*
>    * Miscellaneous XDR helper functions
> 
> 
> 

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:37486 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750741AbdBRWX2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Feb 2017 17:23:28 -0500
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
        by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v1IMMqWG025595
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Sat, 18 Feb 2017 22:22:52 GMT
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 1/4] SUNRPC: Add generic helpers for xdr_stream encode/decode
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170218191246.32687-2-trond.myklebust@primarydata.com>
Date: Sat, 18 Feb 2017 17:21:08 -0500
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0016E411-0100-4CCF-9FCF-541416C4FC1E@oracle.com>
References: <20170218191246.32687-1-trond.myklebust@primarydata.com> <20170218191246.32687-2-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 18, 2017, at 2:12 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> Add some generic helpers for encoding/decoding opaque structures and
> basic u32/u64.

I have some random-thoughts-slash-wacky-ideas.

I'm going to paint the garden shed a little since
these helpers appear to be broadly applicable.
Generally speaking I like the idea of building
"stream" versions of the traditional basic type
encoders and decoders.


> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> include/linux/sunrpc/xdr.h | 173 +++++++++++++++++++++++++++++++++++++++++++++
> 1 file changed, 173 insertions(+)
> 
> diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
> index 56c48c884a24..37bf1be20b62 100644
> --- a/include/linux/sunrpc/xdr.h
> +++ b/include/linux/sunrpc/xdr.h
> @@ -242,6 +242,179 @@ extern unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
> extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
> extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
> 
> +/**
> + * xdr_align_size - Calculate padded size of an object
> + * @n: Size of an object being XDR encoded (in bytes)
> + *
> + * Return value:
> + *   Size (in bytes) of the object including xdr padding
> + */
> +static inline size_t
> +xdr_align_size(size_t n)
> +{
> +	const size_t mask = sizeof(__u32) - 1;

I know this doesn't make a functional difference, but
I'm wondering if this should be sizeof(__be32), since
it is actually the size of a wire object? Seems like
that is a common question wherever sizeof is used
below.

Is this a constant variable rather than an enum because
you want it to retain the type of size_t (matching the
type of the xdr_inline_{en,de}code() functions) ?

Since we see sizeof(yada) repeated elsewhere, did you
consider defining size constants in a scope where they
can be shared amongst all of the XDR functions?

For example, xdr_reserve_space itself could immediately
make use of a "sizeof(__be32) - 1" constant.

Is your intention to replace XDR_QUADLEN with this
function eventually?


> +
> +	return (n + mask) & ~mask;
> +}
> +
> +/**
> + * xdr_stream_encode_u32 - Encode a 32-bit integer
> + * @xdr: pointer to xdr_stream
> + * @n: integer to encode
> + *
> + * Return values:
> + *   On success, returns length in bytes of XDR buffer consumed
> + *   %-ENOBUFS on XDR buffer overflow

I've never been crazy about these amplified return
types, though I know it's typical kernel coding style.
Here, though, I wonder if they are really necessary.

The returned length seems to be interesting only for
decoding variable-length objects (farther below). Maybe
those are the only functions that need to provide a
positive return value?

Perhaps the WARN_ON_ONCE calls added in later patches
should be in these helpers instead of in their callers.
Then the encoder helpers can return void.


> + */
> +static inline ssize_t
> +xdr_stream_encode_u32(struct xdr_stream *xdr, __u32 n)
> +{
> +	const size_t len = sizeof(n);
> +	__be32 *p = xdr_reserve_space(xdr, len);
> +
> +	if (unlikely(!p))
> +		return -ENOBUFS;
> +	*p = cpu_to_be32(n);
> +	return len;
> +}
> +
> +/**
> + * xdr_stream_encode_u64 - Encode a 64-bit integer
> + * @xdr: pointer to xdr_stream
> + * @n: 64-bit integer to encode
> + *
> + * Return values:
> + *   On success, returns length in bytes of XDR buffer consumed
> + *   %-ENOBUFS on XDR buffer overflow
> + */
> +static inline ssize_t
> +xdr_stream_encode_u64(struct xdr_stream *xdr, __u64 n)
> +{
> +	const size_t len = sizeof(n);
> +	__be32 *p = xdr_reserve_space(xdr, len);
> +
> +	if (unlikely(!p))
> +		return -ENOBUFS;
> +	xdr_encode_hyper(p, n);
> +	return len;
> +}
> +
> +/**
> + * xdr_stream_encode_opaque_fixed - Encode fixed length opaque xdr data
> + * @xdr: pointer to xdr_stream
> + * @ptr: pointer to opaque data object
> + * @len: size of object pointed to by @ptr
> + *
> + * Return values:
> + *   On success, returns length in bytes of XDR buffer consumed
> + *   %-ENOBUFS on XDR buffer overflow
> + */
> +static inline ssize_t
> +xdr_stream_encode_opaque_fixed(struct xdr_stream *xdr, const void *ptr, size_t len)
> +{
> +	__be32 *p = xdr_reserve_space(xdr, len);
> +
> +	if (unlikely(!p))
> +		return -ENOBUFS;
> +	xdr_encode_opaque_fixed(p, ptr, len);
> +	return xdr_align_size(len);

Seems like the caller can use xdr_align_size() just as
easily as overloading the return value here, for example.

But I can't think of any fixed-size opaque XDR object
that is not already properly rounded up, or where the
length is not already known to the XDR layer (as a
defined macro constant).


> +}
> +
> +/**
> + * xdr_stream_encode_opaque - Encode variable length opaque xdr data
> + * @xdr: pointer to xdr_stream
> + * @ptr: pointer to opaque data object
> + * @len: size of object pointed to by @ptr
> + *
> + * Return values:
> + *   On success, returns length in bytes of XDR buffer consumed
> + *   %-ENOBUFS on XDR buffer overflow
> + */
> +static inline ssize_t
> +xdr_stream_encode_opaque(struct xdr_stream *xdr, const void *ptr, size_t len)
> +{
> +	size_t count = sizeof(__u32) + xdr_align_size(len);
> +	__be32 *p = xdr_reserve_space(xdr, count);
> +
> +	if (unlikely(!p))
> +		return -ENOBUFS;
> +	xdr_encode_opaque(p, ptr, len);
> +	return count;

These helpers already update the state of the passed
in xdr_stream, so a caller typically would not need
to care much about the bytes consumed by the encoded
opaque.


> +}
> +
> +/**
> + * xdr_stream_decode_u32 - Decode a 32-bit integer
> + * @xdr: pointer to xdr_stream
> + * @ptr: location to store integer
> + *
> + * Return values:
> + *   %0 on success
> + *   %-ENOBUFS on XDR buffer overflow
> + */
> +static inline ssize_t
> +xdr_stream_decode_u32(struct xdr_stream *xdr, __u32 *ptr)
> +{
> +	const size_t count = sizeof(*ptr);
> +	__be32 *p = xdr_inline_decode(xdr, count);
> +
> +	if (unlikely(!p))
> +		return -ENOBUFS;
> +	*ptr = be32_to_cpup(p);
> +	return 0;

No length returned here. The caller knows the length
of this object, clearly, and only cares about whether
decoding has overrun the XDR stream.


> +}
> +
> +/**
> + * xdr_stream_decode_opaque_fixed - Decode fixed length opaque xdr data
> + * @xdr: pointer to xdr_stream
> + * @ptr: location to store data
> + * @len: size of buffer pointed to by @ptr
> + *
> + * Return values:
> + *   On success, returns size of object stored in @ptr

You're returning the passed-in length. Thus the caller
already knows the size of the object stored at @ptr.


> + *   %-ENOBUFS on XDR buffer overflow
> + */
> +static inline ssize_t
> +xdr_stream_decode_opaque_fixed(struct xdr_stream *xdr, void *ptr, size_t len)
> +{
> +	__be32 *p = xdr_inline_decode(xdr, len);
> +
> +	if (unlikely(!p))
> +		return -ENOBUFS;
> +	xdr_decode_opaque_fixed(p, ptr, len);
> +	return len;
> +}
> +
> +/**
> + * xdr_stream_decode_opaque_inline - Decode variable length opaque xdr data
> + * @xdr: pointer to xdr_stream
> + * @ptr: location to store pointer to opaque data
> + *
> + * Note: the pointer stored in @ptr cannot be assumed valid after the XDR
> + * buffer has been destroyed, or even after calling xdr_inline_decode()
> + * on @xdr. It is therefore expected that the object it points to should
> + * be processed immediately.
> + *
> + * Return values:
> + *   On success, returns size of object stored in *@ptr

This seems to be the only function where the caller
might not already know the length of the object, but
might actually care. Since the object length can be
considered part of the object itself, maybe that
length should be returned via an output parameter
rather than as the function's return value.


> + *   %-ENOBUFS on XDR buffer overflow

EINVAL is probably better: the caller didn't provide
the correct inputs. That's a nit, though.

However, as a matter of defensive coding, this errno
could leak up the stack if developers are not careful.

A boolean return value could be entirely adequate for
these decoders?


> + */
> +static inline ssize_t
> +xdr_stream_decode_opaque_inline(struct xdr_stream *xdr, void **ptr)
> +{
> +	__be32 *p;
> +	__u32 len;
> +
> +	if (unlikely(xdr_stream_decode_u32(xdr, &len) < 0))
> +		return -ENOBUFS;
> +	if (len != 0) {
> +		p = xdr_inline_decode(xdr, len);
> +		if (unlikely(!p))
> +			return -ENOBUFS;
> +		*ptr = p;
> +	} else
> +		*ptr = NULL;
> +	return len;
> +}
> #endif /* __KERNEL__ */
> 
> #endif /* _SUNRPC_XDR_H_ */
> -- 
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




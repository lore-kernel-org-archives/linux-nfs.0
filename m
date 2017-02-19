Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21139 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdBSTIA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Feb 2017 14:08:00 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 1/4] SUNRPC: Add generic helpers for xdr_stream encode/decode
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1487482557.70634.2.camel@primarydata.com>
Date: Sun, 19 Feb 2017 14:07:51 -0500
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BD6F57E7-847B-422E-B87D-142DAF475855@oracle.com>
References: <20170218191246.32687-1-trond.myklebust@primarydata.com> <20170218191246.32687-2-trond.myklebust@primarydata.com> <0016E411-0100-4CCF-9FCF-541416C4FC1E@oracle.com> <1487482557.70634.2.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 19, 2017, at 12:36 AM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Sat, 2017-02-18 at 17:21 -0500, Chuck Lever wrote:
>>> On Feb 18, 2017, at 2:12 PM, Trond Myklebust <trond.myklebust@prima
>>> rydata.com> wrote:
>>> 
>>> Add some generic helpers for encoding/decoding opaque structures
>>> and
>>> basic u32/u64.
>> 
>> I have some random-thoughts-slash-wacky-ideas.
>> 
>> I'm going to paint the garden shed a little since
>> these helpers appear to be broadly applicable.
>> Generally speaking I like the idea of building
>> "stream" versions of the traditional basic type
>> encoders and decoders.
>> 
>> 
>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>> ---
>>> include/linux/sunrpc/xdr.h | 173
>>> +++++++++++++++++++++++++++++++++++++++++++++
>>> 1 file changed, 173 insertions(+)
>>> 
>>> diff --git a/include/linux/sunrpc/xdr.h
>>> b/include/linux/sunrpc/xdr.h
>>> index 56c48c884a24..37bf1be20b62 100644
>>> --- a/include/linux/sunrpc/xdr.h
>>> +++ b/include/linux/sunrpc/xdr.h
>>> @@ -242,6 +242,179 @@ extern unsigned int xdr_read_pages(struct
>>> xdr_stream *xdr, unsigned int len);
>>> extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int
>>> len);
>>> extern int xdr_process_buf(struct xdr_buf *buf, unsigned int
>>> offset, unsigned int len, int (*actor)(struct scatterlist *, void
>>> *), void *data);
>>> 
>>> +/**
>>> + * xdr_align_size - Calculate padded size of an object
>>> + * @n: Size of an object being XDR encoded (in bytes)
>>> + *
>>> + * Return value:
>>> + *   Size (in bytes) of the object including xdr padding
>>> + */
>>> +static inline size_t
>>> +xdr_align_size(size_t n)
>>> +{
>>> +	const size_t mask = sizeof(__u32) - 1;
>> 
>> I know this doesn't make a functional difference, but
>> I'm wondering if this should be sizeof(__be32), since
>> it is actually the size of a wire object? Seems like
>> that is a common question wherever sizeof is used
>> below.
> 
> The __be32 is required to be the same size as u32. The only allowed
> difference between the two is be the endianness.

Right, sizeof(__u32) == sizeof(__be32).  __be has always
been about endian annotation; no real functional difference
with __u.

The issue for me is precision of documentation (or, in some
sense, code readability). In all of these cases, it's not
the size of the local variable that is important, it's the
size of the (XDR encoded) wire object. That's sizeof(__be32).

Those just happen to be the same here. It's pretty easy to
mistake the size of a local object as being always the same
as the size of the encoded data type. I've done that myself
often enough that it makes sense to be consistent and
careful, even in the simple cases.

I'm not going to make a big deal, but I'd like to point out
that subtle difference. IMO it would make more sense to
human readers if these were __be and not __u.


>> Is this a constant variable rather than an enum because
>> you want it to retain the type of size_t (matching the
>> type of the xdr_inline_{en,de}code() functions) ?
> 
> It's really just for efficiency, in order to prod gcc into optimising
> it as it would any other constant.
> 
>> Since we see sizeof(yada) repeated elsewhere, did you
>> consider defining size constants in a scope where they
>> can be shared amongst all of the XDR functions?
>> 
>> For example, xdr_reserve_space itself could immediately
>> make use of a "sizeof(__be32) - 1" constant.
> 
> That could be done. I haven't really considered it.
> 
>> Is your intention to replace XDR_QUADLEN with this
>> function eventually?
> 
> Eventually, I'd like us to get rid of most of the open coded instances
> of 'pointer to __be32' in the NFS code, and hide all knowledge of that
> in struct xdr_stream and these SUNRPC layered helpers.

Sounds good to me.


>>> +
>>> +	return (n + mask) & ~mask;
>>> +}
>>> +
>>> +/**
>>> + * xdr_stream_encode_u32 - Encode a 32-bit integer
>>> + * @xdr: pointer to xdr_stream
>>> + * @n: integer to encode
>>> + *
>>> + * Return values:
>>> + *   On success, returns length in bytes of XDR buffer consumed
>>> + *   %-ENOBUFS on XDR buffer overflow
>> 
>> I've never been crazy about these amplified return
>> types, though I know it's typical kernel coding style.
>> Here, though, I wonder if they are really necessary.
>> 
>> The returned length seems to be interesting only for
>> decoding variable-length objects (farther below). Maybe
>> those are the only functions that need to provide a
>> positive return value?
> 
> NFSv4 introduces the (IMO nasty) habit of nesting XDR-encoded objects
> inside a variable length opaque object (say hello to type "attrlist4").

And pNFS layouts. Fair enough.


> In that case, we need to keep a running tally of the length of the
> objects we have XDR encoded so that we can retroactively set the length
> of the opaque object. Currently we use the xdr_stream_pos() to
> determine that length, but it might be nice to replace that with
> something a little more direct.

The new helpers appear to be abstracting away from a
direct approach. IMHO staying with something that looks
like a function call (like xdr_stream_pos) seems like
it is clean and consistent with these new helpers.


> Note also that the lengths returned here are not the object sizes
> themselves, but the amount of buffer space consumed (i.e. the aligned
> size).

Makes sense. Still, seems like the callers already know
these "space consumed" values in every case. Maybe that
won't be true when these helpers are glued together to
handle more abstract data types.


>> Perhaps the WARN_ON_ONCE calls added in later patches
>> should be in these helpers instead of in their callers.
>> Then the encoder helpers can return void.
> 
> At some point, I'd like to reinstate the practice of returning an error
> when encoding fails. It may be better to abort sending a truncated RPC
> call rather than having it execute partially; specially now that we're
> finally starting to use COMPOUND to create more complex operations.

I agree, IMO that would be a better approach.


>>> + */
>>> +static inline ssize_t
>>> +xdr_stream_encode_u32(struct xdr_stream *xdr, __u32 n)
>>> +{
>>> +	const size_t len = sizeof(n);
>>> +	__be32 *p = xdr_reserve_space(xdr, len);
>>> +
>>> +	if (unlikely(!p))
>>> +		return -ENOBUFS;
>>> +	*p = cpu_to_be32(n);
>>> +	return len;
>>> +}
>>> +
>>> +/**
>>> + * xdr_stream_encode_u64 - Encode a 64-bit integer
>>> + * @xdr: pointer to xdr_stream
>>> + * @n: 64-bit integer to encode
>>> + *
>>> + * Return values:
>>> + *   On success, returns length in bytes of XDR buffer consumed
>>> + *   %-ENOBUFS on XDR buffer overflow
>>> + */
>>> +static inline ssize_t
>>> +xdr_stream_encode_u64(struct xdr_stream *xdr, __u64 n)
>>> +{
>>> +	const size_t len = sizeof(n);
>>> +	__be32 *p = xdr_reserve_space(xdr, len);
>>> +
>>> +	if (unlikely(!p))
>>> +		return -ENOBUFS;
>>> +	xdr_encode_hyper(p, n);
>>> +	return len;
>>> +}
>>> +
>>> +/**
>>> + * xdr_stream_encode_opaque_fixed - Encode fixed length opaque xdr
>>> data
>>> + * @xdr: pointer to xdr_stream
>>> + * @ptr: pointer to opaque data object
>>> + * @len: size of object pointed to by @ptr
>>> + *
>>> + * Return values:
>>> + *   On success, returns length in bytes of XDR buffer consumed
>>> + *   %-ENOBUFS on XDR buffer overflow
>>> + */
>>> +static inline ssize_t
>>> +xdr_stream_encode_opaque_fixed(struct xdr_stream *xdr, const void
>>> *ptr, size_t len)
>>> +{
>>> +	__be32 *p = xdr_reserve_space(xdr, len);
>>> +
>>> +	if (unlikely(!p))
>>> +		return -ENOBUFS;
>>> +	xdr_encode_opaque_fixed(p, ptr, len);
>>> +	return xdr_align_size(len);
>> 
>> Seems like the caller can use xdr_align_size() just as
>> easily as overloading the return value here, for example.
>> 
>> But I can't think of any fixed-size opaque XDR object
>> that is not already properly rounded up, or where the
>> length is not already known to the XDR layer (as a
>> defined macro constant).
>> 
>> 
>>> +}
>>> +
>>> +/**
>>> + * xdr_stream_encode_opaque - Encode variable length opaque xdr
>>> data
>>> + * @xdr: pointer to xdr_stream
>>> + * @ptr: pointer to opaque data object
>>> + * @len: size of object pointed to by @ptr
>>> + *
>>> + * Return values:
>>> + *   On success, returns length in bytes of XDR buffer consumed
>>> + *   %-ENOBUFS on XDR buffer overflow
>>> + */
>>> +static inline ssize_t
>>> +xdr_stream_encode_opaque(struct xdr_stream *xdr, const void *ptr,
>>> size_t len)
>>> +{
>>> +	size_t count = sizeof(__u32) + xdr_align_size(len);
>>> +	__be32 *p = xdr_reserve_space(xdr, count);
>>> +
>>> +	if (unlikely(!p))
>>> +		return -ENOBUFS;
>>> +	xdr_encode_opaque(p, ptr, len);
>>> +	return count;
>> 
>> These helpers already update the state of the passed
>> in xdr_stream, so a caller typically would not need
>> to care much about the bytes consumed by the encoded
>> opaque.
>> 
>> 
>>> +}
>>> +
>>> +/**
>>> + * xdr_stream_decode_u32 - Decode a 32-bit integer
>>> + * @xdr: pointer to xdr_stream
>>> + * @ptr: location to store integer
>>> + *
>>> + * Return values:
>>> + *   %0 on success
>>> + *   %-ENOBUFS on XDR buffer overflow
>>> + */
>>> +static inline ssize_t
>>> +xdr_stream_decode_u32(struct xdr_stream *xdr, __u32 *ptr)
>>> +{
>>> +	const size_t count = sizeof(*ptr);
>>> +	__be32 *p = xdr_inline_decode(xdr, count);
>>> +
>>> +	if (unlikely(!p))
>>> +		return -ENOBUFS;
>>> +	*ptr = be32_to_cpup(p);
>>> +	return 0;
>> 
>> No length returned here. The caller knows the length
>> of this object, clearly, and only cares about whether
>> decoding has overrun the XDR stream.
> 
> Yes. Earlier versions returned > 0, but I figured that counting the
> buffer space is not as important when decoding. I can't think of too
> many use cases.
> 
>>> +}
>>> +
>>> +/**
>>> + * xdr_stream_decode_opaque_fixed - Decode fixed length opaque xdr
>>> data
>>> + * @xdr: pointer to xdr_stream
>>> + * @ptr: location to store data
>>> + * @len: size of buffer pointed to by @ptr
>>> + *
>>> + * Return values:
>>> + *   On success, returns size of object stored in @ptr
>> 
>> You're returning the passed-in length. Thus the caller
>> already knows the size of the object stored at @ptr.
> 
> Consistency, and it allows it to be easily used as a helper inside
> other functions that do need to return the object length.

Going for ease of composing these functions. OK.


> Note that the function is inlined, so the compiler should normally
> optimise away return values that are unused by the caller.

True. However future code readers might wonder why this
value is being computed if the value or the computation
itself is unneeded in most cases.

Seems like a separate helper that derives this value
where and when it is needed might be cleaner; but that
is entirely subjective.


>>> + *   %-ENOBUFS on XDR buffer overflow
>>> + */
>>> +static inline ssize_t
>>> +xdr_stream_decode_opaque_fixed(struct xdr_stream *xdr, void *ptr,
>>> size_t len)
>>> +{
>>> +	__be32 *p = xdr_inline_decode(xdr, len);
>>> +
>>> +	if (unlikely(!p))
>>> +		return -ENOBUFS;
>>> +	xdr_decode_opaque_fixed(p, ptr, len);
>>> +	return len;
>>> +}
>>> +
>>> +/**
>>> + * xdr_stream_decode_opaque_inline - Decode variable length opaque
>>> xdr data
>>> + * @xdr: pointer to xdr_stream
>>> + * @ptr: location to store pointer to opaque data
>>> + *
>>> + * Note: the pointer stored in @ptr cannot be assumed valid after
>>> the XDR
>>> + * buffer has been destroyed, or even after calling
>>> xdr_inline_decode()
>>> + * on @xdr. It is therefore expected that the object it points to
>>> should
>>> + * be processed immediately.
>>> + *
>>> + * Return values:
>>> + *   On success, returns size of object stored in *@ptr
>> 
>> This seems to be the only function where the caller
>> might not already know the length of the object, but
>> might actually care. Since the object length can be
>> considered part of the object itself, maybe that
>> length should be returned via an output parameter
>> rather than as the function's return value.
> 
> I considered it, but that means you have to choose an exact storage
> type and gcc will complain if the type check fails.
> In most cases, we don't really care if the u32 value gets stored in an
> unsigned int, int, unsigned long, long, size_t, ssize_t because we have
> a good idea of what to expect for the object size.
> 
>>> + *   %-ENOBUFS on XDR buffer overflow
>> 
>> EINVAL is probably better: the caller didn't provide
>> the correct inputs. That's a nit, though.
> 
> It's not a caller problem. The ENOBUFS error on decode indicates that
> the RPC message we're trying to decode was probably truncated or
> corrupted.

Ah. Agree now, not a caller bug.

I still wonder if the meaning of ENOBUFS is a good enough match
to this use case. EINVAL is a permanent error, but I don't think
ENOBUFS is.

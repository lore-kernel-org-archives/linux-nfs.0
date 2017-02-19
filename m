Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17713 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdBSUG0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Feb 2017 15:06:26 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 1/4] SUNRPC: Add generic helpers for xdr_stream encode/decode
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1487532489.42276.1.camel@primarydata.com>
Date: Sun, 19 Feb 2017 15:06:06 -0500
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7ABA2E55-A24E-4765-865F-B5B103BDC8FA@oracle.com>
References: <20170218191246.32687-1-trond.myklebust@primarydata.com> <20170218191246.32687-2-trond.myklebust@primarydata.com> <0016E411-0100-4CCF-9FCF-541416C4FC1E@oracle.com> <1487482557.70634.2.camel@primarydata.com> <BD6F57E7-847B-422E-B87D-142DAF475855@oracle.com> <1487532489.42276.1.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 19, 2017, at 2:28 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> Thanks for the discussion, BTW. I appreciate the feedback.

No problem! Feel free to add

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> On Sun, 2017-02-19 at 14:07 -0500, Chuck Lever wrote:
>>> On Feb 19, 2017, at 12:36 AM, Trond Myklebust <trondmy@primarydata.
>>> com> wrote:
>>> 
>>> On Sat, 2017-02-18 at 17:21 -0500, Chuck Lever wrote:
>>>>> On Feb 18, 2017, at 2:12 PM, Trond Myklebust <trond.myklebust@p
>>>>> rima
>>>>> rydata.com> wrote:
>>>>> 
>>>>> Add some generic helpers for encoding/decoding opaque
>>>>> structures
>>>>> and
>>>>> basic u32/u64.
>>>> 
>>>> I have some random-thoughts-slash-wacky-ideas.
>>>> 
>>>> I'm going to paint the garden shed a little since
>>>> these helpers appear to be broadly applicable.
>>>> Generally speaking I like the idea of building
>>>> "stream" versions of the traditional basic type
>>>> encoders and decoders.
>>>> 
>>>> 
>>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com
>>>>>> 
>>>>> ---
>>>>> include/linux/sunrpc/xdr.h | 173
>>>>> +++++++++++++++++++++++++++++++++++++++++++++
>>>>> 1 file changed, 173 insertions(+)
>>>>> 
>>>>> diff --git a/include/linux/sunrpc/xdr.h
>>>>> b/include/linux/sunrpc/xdr.h
>>>>> index 56c48c884a24..37bf1be20b62 100644
>>>>> --- a/include/linux/sunrpc/xdr.h
>>>>> +++ b/include/linux/sunrpc/xdr.h
>>>>> @@ -242,6 +242,179 @@ extern unsigned int xdr_read_pages(struct
>>>>> xdr_stream *xdr, unsigned int len);
>>>>> extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int
>>>>> len);
>>>>> extern int xdr_process_buf(struct xdr_buf *buf, unsigned int
>>>>> offset, unsigned int len, int (*actor)(struct scatterlist *,
>>>>> void
>>>>> *), void *data);
>>>>> 
>>>>> +/**
>>>>> + * xdr_align_size - Calculate padded size of an object
>>>>> + * @n: Size of an object being XDR encoded (in bytes)
>>>>> + *
>>>>> + * Return value:
>>>>> + *   Size (in bytes) of the object including xdr padding
>>>>> + */
>>>>> +static inline size_t
>>>>> +xdr_align_size(size_t n)
>>>>> +{
>>>>> +	const size_t mask = sizeof(__u32) - 1;
>>>> 
>>>> I know this doesn't make a functional difference, but
>>>> I'm wondering if this should be sizeof(__be32), since
>>>> it is actually the size of a wire object? Seems like
>>>> that is a common question wherever sizeof is used
>>>> below.
>>> 
>>> The __be32 is required to be the same size as u32. The only allowed
>>> difference between the two is be the endianness.
>> 
>> Right, sizeof(__u32) == sizeof(__be32).  __be has always
>> been about endian annotation; no real functional difference
>> with __u.
>> 
>> The issue for me is precision of documentation (or, in some
>> sense, code readability). In all of these cases, it's not
>> the size of the local variable that is important, it's the
>> size of the (XDR encoded) wire object. That's sizeof(__be32).
>> 
>> Those just happen to be the same here. It's pretty easy to
>> mistake the size of a local object as being always the same
>> as the size of the encoded data type. I've done that myself
>> often enough that it makes sense to be consistent and
>> careful, even in the simple cases.
>> 
>> I'm not going to make a big deal, but I'd like to point out
>> that subtle difference. IMO it would make more sense to
>> human readers if these were __be and not __u.
> 
> Fair enough. I can update that.
> 
>> 
>>>> Is this a constant variable rather than an enum because
>>>> you want it to retain the type of size_t (matching the
>>>> type of the xdr_inline_{en,de}code() functions) ?
>>> 
>>> It's really just for efficiency, in order to prod gcc into
>>> optimising
>>> it as it would any other constant.
>>> 
>>>> Since we see sizeof(yada) repeated elsewhere, did you
>>>> consider defining size constants in a scope where they
>>>> can be shared amongst all of the XDR functions?
>>>> 
>>>> For example, xdr_reserve_space itself could immediately
>>>> make use of a "sizeof(__be32) - 1" constant.
>>> 
>>> That could be done. I haven't really considered it.
>>> 
>>>> Is your intention to replace XDR_QUADLEN with this
>>>> function eventually?
>>> 
>>> Eventually, I'd like us to get rid of most of the open coded
>>> instances
>>> of 'pointer to __be32' in the NFS code, and hide all knowledge of
>>> that
>>> in struct xdr_stream and these SUNRPC layered helpers.
>> 
>> Sounds good to me.
>> 
>> 
>>>>> +
>>>>> +	return (n + mask) & ~mask;
>>>>> +}
>>>>> +
>>>>> +/**
>>>>> + * xdr_stream_encode_u32 - Encode a 32-bit integer
>>>>> + * @xdr: pointer to xdr_stream
>>>>> + * @n: integer to encode
>>>>> + *
>>>>> + * Return values:
>>>>> + *   On success, returns length in bytes of XDR buffer
>>>>> consumed
>>>>> + *   %-ENOBUFS on XDR buffer overflow
>>>> 
>>>> I've never been crazy about these amplified return
>>>> types, though I know it's typical kernel coding style.
>>>> Here, though, I wonder if they are really necessary.
>>>> 
>>>> The returned length seems to be interesting only for
>>>> decoding variable-length objects (farther below). Maybe
>>>> those are the only functions that need to provide a
>>>> positive return value?
>>> 
>>> NFSv4 introduces the (IMO nasty) habit of nesting XDR-encoded
>>> objects
>>> inside a variable length opaque object (say hello to type
>>> "attrlist4").
>> 
>> And pNFS layouts. Fair enough.
>> 
>> 
>>> In that case, we need to keep a running tally of the length of the
>>> objects we have XDR encoded so that we can retroactively set the
>>> length
>>> of the opaque object. Currently we use the xdr_stream_pos() to
>>> determine that length, but it might be nice to replace that with
>>> something a little more direct.
>> 
>> The new helpers appear to be abstracting away from a
>> direct approach. IMHO staying with something that looks
>> like a function call (like xdr_stream_pos) seems like
>> it is clean and consistent with these new helpers.
>> 
>> 
>>> Note also that the lengths returned here are not the object sizes
>>> themselves, but the amount of buffer space consumed (i.e. the
>>> aligned
>>> size).
>> 
>> Makes sense. Still, seems like the callers already know
>> these "space consumed" values in every case. Maybe that
>> won't be true when these helpers are glued together to
>> handle more abstract data types.
>> 
>>>> Perhaps the WARN_ON_ONCE calls added in later patches
>>>> should be in these helpers instead of in their callers.
>>>> Then the encoder helpers can return void.
>>> 
>>> At some point, I'd like to reinstate the practice of returning an
>>> error
>>> when encoding fails. It may be better to abort sending a truncated
>>> RPC
>>> call rather than having it execute partially; specially now that
>>> we're
>>> finally starting to use COMPOUND to create more complex operations.
>> 
>> I agree, IMO that would be a better approach.
>> 
>> 
>>>>> + */
>>>>> +static inline ssize_t
>>>>> +xdr_stream_encode_u32(struct xdr_stream *xdr, __u32 n)
>>>>> +{
>>>>> +	const size_t len = sizeof(n);
>>>>> +	__be32 *p = xdr_reserve_space(xdr, len);
>>>>> +
>>>>> +	if (unlikely(!p))
>>>>> +		return -ENOBUFS;
>>>>> +	*p = cpu_to_be32(n);
>>>>> +	return len;
>>>>> +}
>>>>> +
>>>>> +/**
>>>>> + * xdr_stream_encode_u64 - Encode a 64-bit integer
>>>>> + * @xdr: pointer to xdr_stream
>>>>> + * @n: 64-bit integer to encode
>>>>> + *
>>>>> + * Return values:
>>>>> + *   On success, returns length in bytes of XDR buffer
>>>>> consumed
>>>>> + *   %-ENOBUFS on XDR buffer overflow
>>>>> + */
>>>>> +static inline ssize_t
>>>>> +xdr_stream_encode_u64(struct xdr_stream *xdr, __u64 n)
>>>>> +{
>>>>> +	const size_t len = sizeof(n);
>>>>> +	__be32 *p = xdr_reserve_space(xdr, len);
>>>>> +
>>>>> +	if (unlikely(!p))
>>>>> +		return -ENOBUFS;
>>>>> +	xdr_encode_hyper(p, n);
>>>>> +	return len;
>>>>> +}
>>>>> +
>>>>> +/**
>>>>> + * xdr_stream_encode_opaque_fixed - Encode fixed length opaque
>>>>> xdr
>>>>> data
>>>>> + * @xdr: pointer to xdr_stream
>>>>> + * @ptr: pointer to opaque data object
>>>>> + * @len: size of object pointed to by @ptr
>>>>> + *
>>>>> + * Return values:
>>>>> + *   On success, returns length in bytes of XDR buffer
>>>>> consumed
>>>>> + *   %-ENOBUFS on XDR buffer overflow
>>>>> + */
>>>>> +static inline ssize_t
>>>>> +xdr_stream_encode_opaque_fixed(struct xdr_stream *xdr, const
>>>>> void
>>>>> *ptr, size_t len)
>>>>> +{
>>>>> +	__be32 *p = xdr_reserve_space(xdr, len);
>>>>> +
>>>>> +	if (unlikely(!p))
>>>>> +		return -ENOBUFS;
>>>>> +	xdr_encode_opaque_fixed(p, ptr, len);
>>>>> +	return xdr_align_size(len);
>>>> 
>>>> Seems like the caller can use xdr_align_size() just as
>>>> easily as overloading the return value here, for example.
>>>> 
>>>> But I can't think of any fixed-size opaque XDR object
>>>> that is not already properly rounded up, or where the
>>>> length is not already known to the XDR layer (as a
>>>> defined macro constant).
>>>> 
>>>> 
>>>>> +}
>>>>> +
>>>>> +/**
>>>>> + * xdr_stream_encode_opaque - Encode variable length opaque
>>>>> xdr
>>>>> data
>>>>> + * @xdr: pointer to xdr_stream
>>>>> + * @ptr: pointer to opaque data object
>>>>> + * @len: size of object pointed to by @ptr
>>>>> + *
>>>>> + * Return values:
>>>>> + *   On success, returns length in bytes of XDR buffer
>>>>> consumed
>>>>> + *   %-ENOBUFS on XDR buffer overflow
>>>>> + */
>>>>> +static inline ssize_t
>>>>> +xdr_stream_encode_opaque(struct xdr_stream *xdr, const void
>>>>> *ptr,
>>>>> size_t len)
>>>>> +{
>>>>> +	size_t count = sizeof(__u32) + xdr_align_size(len);
>>>>> +	__be32 *p = xdr_reserve_space(xdr, count);
>>>>> +
>>>>> +	if (unlikely(!p))
>>>>> +		return -ENOBUFS;
>>>>> +	xdr_encode_opaque(p, ptr, len);
>>>>> +	return count;
>>>> 
>>>> These helpers already update the state of the passed
>>>> in xdr_stream, so a caller typically would not need
>>>> to care much about the bytes consumed by the encoded
>>>> opaque.
>>>> 
>>>> 
>>>>> +}
>>>>> +
>>>>> +/**
>>>>> + * xdr_stream_decode_u32 - Decode a 32-bit integer
>>>>> + * @xdr: pointer to xdr_stream
>>>>> + * @ptr: location to store integer
>>>>> + *
>>>>> + * Return values:
>>>>> + *   %0 on success
>>>>> + *   %-ENOBUFS on XDR buffer overflow
>>>>> + */
>>>>> +static inline ssize_t
>>>>> +xdr_stream_decode_u32(struct xdr_stream *xdr, __u32 *ptr)
>>>>> +{
>>>>> +	const size_t count = sizeof(*ptr);
>>>>> +	__be32 *p = xdr_inline_decode(xdr, count);
>>>>> +
>>>>> +	if (unlikely(!p))
>>>>> +		return -ENOBUFS;
>>>>> +	*ptr = be32_to_cpup(p);
>>>>> +	return 0;
>>>> 
>>>> No length returned here. The caller knows the length
>>>> of this object, clearly, and only cares about whether
>>>> decoding has overrun the XDR stream.
>>> 
>>> Yes. Earlier versions returned > 0, but I figured that counting the
>>> buffer space is not as important when decoding. I can't think of
>>> too
>>> many use cases.
>>> 
>>>>> +}
>>>>> +
>>>>> +/**
>>>>> + * xdr_stream_decode_opaque_fixed - Decode fixed length opaque
>>>>> xdr
>>>>> data
>>>>> + * @xdr: pointer to xdr_stream
>>>>> + * @ptr: location to store data
>>>>> + * @len: size of buffer pointed to by @ptr
>>>>> + *
>>>>> + * Return values:
>>>>> + *   On success, returns size of object stored in @ptr
>>>> 
>>>> You're returning the passed-in length. Thus the caller
>>>> already knows the size of the object stored at @ptr.
>>> 
>>> Consistency, and it allows it to be easily used as a helper inside
>>> other functions that do need to return the object length.
>> 
>> Going for ease of composing these functions. OK.
>> 
>> 
>>> Note that the function is inlined, so the compiler should normally
>>> optimise away return values that are unused by the caller.
>> 
>> True. However future code readers might wonder why this
>> value is being computed if the value or the computation
>> itself is unneeded in most cases.
>> 
>> Seems like a separate helper that derives this value
>> where and when it is needed might be cleaner; but that
>> is entirely subjective.
>> 
>> 
>>>>> + *   %-ENOBUFS on XDR buffer overflow
>>>>> + */
>>>>> +static inline ssize_t
>>>>> +xdr_stream_decode_opaque_fixed(struct xdr_stream *xdr, void
>>>>> *ptr,
>>>>> size_t len)
>>>>> +{
>>>>> +	__be32 *p = xdr_inline_decode(xdr, len);
>>>>> +
>>>>> +	if (unlikely(!p))
>>>>> +		return -ENOBUFS;
>>>>> +	xdr_decode_opaque_fixed(p, ptr, len);
>>>>> +	return len;
>>>>> +}
>>>>> +
>>>>> +/**
>>>>> + * xdr_stream_decode_opaque_inline - Decode variable length
>>>>> opaque
>>>>> xdr data
>>>>> + * @xdr: pointer to xdr_stream
>>>>> + * @ptr: location to store pointer to opaque data
>>>>> + *
>>>>> + * Note: the pointer stored in @ptr cannot be assumed valid
>>>>> after
>>>>> the XDR
>>>>> + * buffer has been destroyed, or even after calling
>>>>> xdr_inline_decode()
>>>>> + * on @xdr. It is therefore expected that the object it points
>>>>> to
>>>>> should
>>>>> + * be processed immediately.
>>>>> + *
>>>>> + * Return values:
>>>>> + *   On success, returns size of object stored in *@ptr
>>>> 
>>>> This seems to be the only function where the caller
>>>> might not already know the length of the object, but
>>>> might actually care. Since the object length can be
>>>> considered part of the object itself, maybe that
>>>> length should be returned via an output parameter
>>>> rather than as the function's return value.
>>> 
>>> I considered it, but that means you have to choose an exact storage
>>> type and gcc will complain if the type check fails.
>>> In most cases, we don't really care if the u32 value gets stored in
>>> an
>>> unsigned int, int, unsigned long, long, size_t, ssize_t because we
>>> have
>>> a good idea of what to expect for the object size.
>>> 
>>>>> + *   %-ENOBUFS on XDR buffer overflow
>>>> 
>>>> EINVAL is probably better: the caller didn't provide
>>>> the correct inputs. That's a nit, though.
>>> 
>>> It's not a caller problem. The ENOBUFS error on decode indicates
>>> that
>>> the RPC message we're trying to decode was probably truncated or
>>> corrupted.
>> 
>> Ah. Agree now, not a caller bug.
>> 
>> I still wonder if the meaning of ENOBUFS is a good enough match
>> to this use case. EINVAL is a permanent error, but I don't think
>> ENOBUFS is.
>> 
>> From https://www.gnu.org/software/libc/manual/html_node/Error-Codes.h
>> tml:
>> 
>>> Macro: int ENOBUFS
>>> The kernel’s buffers for I/O operations are all in use. In GNU,
>>> this
>>> error is always synonymous with ENOMEM; you may get one or the
>>> other
>>> from network operations.
>> 
>> The other places I've looked also suggest this error code means
>> a temporary out of buffers condition, and the caller should try
>> again later. The error is used to mean there are no more buffers
>> (plural) to use for a send operation. As it says, akin to ENOMEM.
>> That's the way I've used this errno in the past.
>> 
>> Here the error is used to mean "buffer (singular) would overflow"
>> during a receive; permanent error, no retry possible. Possible
>> alternatives that might be closer in purpose: EMSGSIZE, EBADMSG,
>> EREMOTEIO, or E2BIG.
> 
> How about ENODATA, then?

ENODATA is indeed a permanent error. To me, EBADMSG still
feels closer to a decode failure.

Other systems have EBADRPC, but Linux doesn't appear to.

On the encode side, EINVAL or the venerable EIO makes sense.
Both seem to be used for a lot of other purposes in the RPC
stack, though.

It would be great to have one distinct error code meaning
"failed to encode Call" and one meaning "failed to decode
Reply". For instance, TI-RPC has

 21 enum clnt_stat {
 22         RPC_SUCCESS = 0,                /* call succeeded */
 23         /*
 24          * local errors
 25          */
 26         RPC_CANTENCODEARGS = 1,         /* can't encode arguments */
 27         RPC_CANTDECODERES = 2,          /* can't decode results */
 28         RPC_CANTSEND = 3,               /* failure in sending call */
 29         RPC_CANTRECV = 4,

Maybe that's over-engineering for us, but there could be
some instances where it might help the upper layer to know
that the RPC Call was never sent (like, SEQUENCE ? ).


>> I assume you want to return errnos from these helpers because
>> eventually some of them might encounter other types of errors?
>> If not, then sticking with -1 on error, 0 or positive value on
>> success might be entirely adequate.
> 
> See the "v4" patchset which goes a little further in replacing the
> object size checks. For one thing, that allows us to be more forceful
> about ensuring that we _always_ check the size of the object against
> expectations.

Glanced at that. Yes, that's more clear, and length checking
in addition to buffer overrun checking is good.

Why would the upper layer want to distinguish those two cases.
Are there some cases where the UL can take some recourse, or
is a decoding failure always permanent?


>>>> However, as a matter of defensive coding, this errno
>>>> could leak up the stack if developers are not careful.
>>>> 
>>>> A boolean return value could be entirely adequate for
>>>> these decoders?
>>>> 
>>>> 
>>>>> + */
>>>>> +static inline ssize_t
>>>>> +xdr_stream_decode_opaque_inline(struct xdr_stream *xdr, void
>>>>> **ptr)
>>>>> +{
>>>>> +	__be32 *p;
>>>>> +	__u32 len;
>>>>> +
>>>>> +	if (unlikely(xdr_stream_decode_u32(xdr, &len) < 0))
>>>>> +		return -ENOBUFS;
>>>>> +	if (len != 0) {
>>>>> +		p = xdr_inline_decode(xdr, len);
>>>>> +		if (unlikely(!p))
>>>>> +			return -ENOBUFS;
>>>>> +		*ptr = p;
>>>>> +	} else
>>>>> +		*ptr = NULL;
>>>>> +	return len;
>>>>> +}
>>>>> #endif /* __KERNEL__ */
>>>>> 
>>>>> #endif /* _SUNRPC_XDR_H_ */
>>>>> -- 
>>>>> 2.9.3
>>>>> 
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe
>>>>> linux-
>>>>> nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.h
>>>>> tml
>>>> 
>>>> --
>>>> Chuck Lever
>>>> 
>>>> 
>>>> 
>>> 
>>> -- 
>>> Trond Myklebust
>>> Linux NFS client maintainer, PrimaryData
>>> trond.myklebust@primarydata.com
>>> N���r�y���b�X�ǧv�^�)޺{.n�+�{�"��^n�r��z���h���&��G��h�(�階�ݢj"��
>>> m����z�ޖ��f�h�~�m
>> 
>> --
>> Chuck Lever
>> 
>> 
>> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com

--
Chuck Lever




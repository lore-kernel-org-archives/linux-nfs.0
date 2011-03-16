Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272Ab1CPW6U convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2011 18:58:20 -0400
Subject: Re: Bug in xdr_copy_to_scratch???
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110317093838.0f15eb98@notabene.brown>
References: <20110316213642.360be61d@notabene.brown>
	 <1300282974.16266.33.camel@lade.trondhjem.org>
	 <20110317093838.0f15eb98@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Mar 2011 18:57:02 -0400
Message-ID: <1300316222.8295.5.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-03-17 at 09:38 +1100, NeilBrown wrote:
> On Wed, 16 Mar 2011 09:42:54 -0400 Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> 
> > On Wed, 2011-03-16 at 21:36 +1100, NeilBrown wrote:
> > > Hi Trond,
> > > 
> > >  I'm currently trying to track down the cause of some very
> > > odd behaviour in readdir in openSUSE 11.4 (2.6.37.3 based).
> > > 
> > > I think it might be caused by xdr_copy_to_scratch not quite
> > > behaving correctly.
> > > 
> > > In particular, when it has to copy into the scratch buffer
> > > it only copies 'nbytes' bytes - which sounds reasonable but
> > > isn't.  It should copy XDR_QUADLEN(nbytes) words.
> > > 
> > > In particular, nfs3_decode_dirent contains:
> > > 
> > > 	p = xdr_inline_decode(xdr, entry->len + 8);
> > > 	if (unlikely(!p))
> > > 		goto out_overflow;
> > > 	entry->name = (const char *) p;
> > > 	p += XDR_QUADLEN(entry->len);
> > > 	entry->prev_cookie = entry->cookie;
> > > 	p = xdr_decode_hyper(p, &entry->cookie);
> > > 
> > > 
> > > where the cookie needs all of those last few bytes which
> > > we would only get by rounding nbytes up to a multiple of 4.
> > > 
> > > 
> > > I haven't developed or tested a fix yet, but as it is clearly a bug,
> > > I thought I would let you know before I call it a night.
> > 
> > Hi Neil,
> > 
> > I'm not sure I 100% agree that is a bug in xdr_copy_to_scratch(). I
> > think it is rather an artifact of the fact that xdr_inline_decode takes
> > a byte argument instead of a word argument, which means that combining
> > buffer lengths needs to done with care: my fault :-(.
> > 
> > To illustrate what I mean, consider the following snippet of xdr:
> > 
> > 	p = xdr_decode_inline(xdr, len1 + len2);
> > 	name1 = p;
> > 	p += XDR_QUADLEN(len1);
> > 	name2 = p;
> > 
> > No matter what we do in xdr_decode_inline(), there is no way we can
> > determine the true value of XDR_QUADLEN(len1)<<2 + XDR_QUADLEN(len2)<<2
> > if len1 and len2 are arbitrary buffer lengths.
> > 
> > So I'd argue that while we could fix this issue in xdr_copy_to_scratch
> > for this particular case, in reality nfs3_decode_dirent should not be
> > asking for a buffer of (entry->len + 8) bytes when it knows there is an
> > alignment issue due to the fact that the 8 cookie bytes follows the
> > string.
> 
> Your argument certainly has some merit.
> Probably the question to ask is "what sort of fix is most likely to
> avoid such problems recurring in the future", and I cannot convince myself
> that either is clearly better than the other on that basis.
> 
> I note that in 2.6.38 the readdir problem has been 'fixed' by the
> introduction of decode_inline_filename3 and similar functions.
> However there is still one place where xdr_decode_inline is used in
> an unsafe way - see patch below.
> 
> We should probably submit a fix to 2.6.37-stable though.  For that it
> is possibly simplest to tell xdr_decode_inline to round nbytes up to
> a multiple of 4 - would you agree?

The only case that seems affected is nfs3_decode_dirent(). The other
decode_dirent cases are all OK AFAICS.

> Also:  looking at xdr_copy_to_scratch again, is there any chance that
> 'cplen' could not be a multiple of 4?  I think not but I'm not
> 100% sure.  If it were not a multiple of 4, then the
> __xdr_inline_decode call would do the wrong thing.

If it is not a multiple of 4, then that would mean we must have decoded
the preceding xdr-encoded buffer incorrectly.

> And finally - it bothers me a little bit that a call to xdr_copy_to_scratch
> will corrupt the value returned by the previous call to
> xdr_copy_to_scratch.  This is unlikely to be a problem as you
> get at most one of those calls every 4096 bytes, and the previous
> value will almost certainly have been used before the next value
> is copied over it.  But it isn't clear what guarantees that it will
> have been used, so a future change or extension to the protocol could
> conceivably result in corruption happening in the scratch buffer.
> Maybe it isn't worth worrying about.... not sure.

The long term solution is to switch to using words instead of bytes as
the argument to xdr_inline_decode(). If we force people to use
XDR_QUADLEN() on non-word sized arguments, then that will avoid any
confusion.

> 
> Fix theoretical decoding problem in nfsv4 compound header decoding.
> 
> As all XDR encoded fields are rounded up to a multiple of 4
> bytes in size, a string field followed by a number field could
> have padding between the string and number.
> 
> If xdr_inline_decode is asked to decode the combined field
> (by summing the lengths) it will normally work.  However if it
> needs to copy the field into that 'scratch' space to avoid a
> break between pages, it will only copy the requested number of bytes,
> as it assumes any padding is at the end - so the number field will not be
> fully copied.
> 
> So in decode_compound_hdr, call xdr_inline_decode twice instead of
> risking an incorrect decode.
> 
> As this field is always near the start of a packet, the chance that it
> will ever cross a page boundary and so cause a problem is vanishingly small,
> but having 'wrong' code could set an example that might get copied. 
> So fix it anyway.
> 
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 4e2c168..c52b50c 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -2638,11 +2638,13 @@ static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
>  	hdr->status = be32_to_cpup(p++);
>  	hdr->taglen = be32_to_cpup(p);
>  
> -	p = xdr_inline_decode(xdr, hdr->taglen + 4);
> +	p = xdr_inline_decode(xdr, hdr->taglen);
>  	if (unlikely(!p))
>  		goto out_overflow;
>  	hdr->tag = (char *)p;
> -	p += XDR_QUADLEN(hdr->taglen);
> +	p = xdr_inline_decode(xdr, 4);
> +	if (unlikely(!p))
> +		goto out_overflow;
>  	hdr->nops = be32_to_cpup(p);
>  	if (unlikely(hdr->nops < 1))
>  		return nfs4_stat_to_errno(hdr->status);

There is a similar instance in fs/nfsd/nfs4callback.c: see
decode_cb_compound4res().

Might as well fix both in the same way.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


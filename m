From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [pnfs] [PATCH RFC v2 0/21] nfs4xdr cleanup v2
Date: Mon, 17 Aug 2009 12:48:12 -0400
Message-ID: <1250527692.20012.26.camel@heimdal.trondhjem.org>
References: <4A8571E2.8020800@panasas.com>  <4A89338D.1040207@panasas.com>
	 <1250513254.8475.20.camel@heimdal.trondhjem.org>
	 <4A896125.2040506@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54906 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757021AbZHQQuT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Aug 2009 12:50:19 -0400
In-Reply-To: <4A896125.2040506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-08-17 at 16:54 +0300, Boaz Harrosh wrote:
> On 08/17/2009 03:47 PM, Trond Myklebust wrote:
> > Adding wrappers to do this, is just unnecessarily obfuscating the code.
> > 
> 
> As I said, *sometimes* "obfuscation" is the point. If it has merits to account
> for human short concentration span.

In this case, the change was motivated by a bunch of patches which were
doing things like adding dummy READ32 requests immediately prior to a
READ_BUF() call. It was therefore abundantly clear that the obfuscation
was helping no-one, even though it may have made it easy to churn out
bad code quickly.

> >> * I hate it that I have to count (p)"++" now to look for actual code advancements.
> > 
> > How is that _any_ different from counting WRITE32s?
> > 
> 
> The size for one. And mainly the symmetry with the other side of the wire.
> 
> WRITEXX for every READXX. What now?

A

	*p++ = cpu_to_be32(foo); // WRITE32(foo)

for every

	foo = be32_to_cpu(*p++); // READ32(foo)
 
> >> * I hated it before, but I hate it even more now that the same operation is:
> >>   reserved(4); p + 1
> > 
> > Huh? What operation?
> > 
> 
> Sorry, I meant the mix use of byte_sizes and word_sizes. For example I'd like
> reserved(1); p + 1;
> and reserved(quad_len(len)); p + quad_len(len);

That's probably worth doing. We could split up xdr_inline_decode() into
something like the following:

__be32 *xdr_decode_words(struct xdr_stream *xdr, size_t nwords)
{
	__be32 *p = xdr->p;
	__be32 *q = p + nwords;

	if (unlikely(q > xdr->end || q < p))
		return NULL;
	xdr->p = q;
	return p;
}

__be32 *xdr_decode_inline(struct xdr_stream *xdr, size_t nbytes)
{
	return xdr_decode_words(xdr, XDR_QUADLEN(nbytes));
}

The latter would be used for decoding 'opaque' or string objects,
whereas the former could be used for decoding 32-bit words.

> Only one request though. Please make nfs and nfsd use the same xdr mechanics

Bruce has already stated he wants to remove the macros on the nfsd side.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

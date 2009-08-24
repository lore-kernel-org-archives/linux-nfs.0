From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [pnfs] [PATCH RFC v2 0/21] nfs4xdr cleanup v2
Date: Mon, 24 Aug 2009 08:59:14 -0400
Message-ID: <1251118754.6325.47.camel@heimdal.trondhjem.org>
References: <4A8571E2.8020800@panasas.com>  <4A89338D.1040207@panasas.com>
	 <1250513254.8475.20.camel@heimdal.trondhjem.org>
	 <4A896125.2040506@panasas.com>
	 <1250527692.20012.26.camel@heimdal.trondhjem.org>
	 <4A9240C7.5090307@panasas.com>
	 <1251115007.6325.9.camel@heimdal.trondhjem.org>
	 <4A928CA7.8070306@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5021 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752376AbZHXM7a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2009 08:59:30 -0400
In-Reply-To: <4A928CA7.8070306@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-08-24 at 15:50 +0300, Boaz Harrosh wrote:
> On 08/24/2009 02:56 PM, Trond Myklebust wrote:
> > On Mon, 2009-08-24 at 10:27 +0300, Boaz Harrosh wrote:
> >> OK I used the new stuff by now, and I'm happy with everything
> >> but the above. I *absolutely* insist on this changing to:
> > 
> > Feel quite free to insist, but the patch isn't going in.
> > 
> 
> I think your being irrational here. I'm not the first that wants this, it has
> been brought up again and again on the mailing list. The big majority of nfs/xdr
> programmers want this. In fact you are the *only one* who's against it.

I saw your call for a show of hands, but have yet to see any replies. It
is probably a bit early for you to start talking about big majorities...

In any case, I don't apply patches based on popular vote. I apply them
based on my conviction that they are useful.

> >> 	p = xdr_encode_word(p, foo);
> >> and 
> >> 	p = xdr_decode_word(p, &foo);
> >>
> >> [xdr_{encode,decode}_word is defined differently but is only used in a couple
> >>  of sunrpc files, the change of these places shall be added to this cleanup]
> >>
> >> I have checked this version of the definition:
> >>  static inline __be32 *
> >>  xdr_encode_word(__be32 *p, __u32 val)
> >>  {
> >> 	*p++ = cpu_to_be32(val);
> >> 	return p;
> >>  }
> >>
> >>  static inline __be32 *
> >>  xdr_decode_word(__be32 *p, __u32 *valp)
> >>  {
> >> 	*valp = be32_to_cpu(*p++);
> >> 	return p;
> >>  }
> >>
> >> under assembly with gcc -O2 and it gives the exact same result as the open code,
> >> so I do not see what can be said against it?
> > 
> > It is unnecessary, 
> 
> Yes it is necessary, for the reader. (And the writer).
> 
> it looks ugly, 
> 
> I think it is not, that's a matter of taste, no? The opposite is true, your
> option is the ugly one.
> 
> > the latter form takes 2 pointers and
> > hides an assignment, it does an unconditional pointer increment.
> > 
> 
> So do all the other xdr_{de,en}code_xxx I don't see a choice. Some eggs most
> be broken when making a cake. It is totally uniform with the reset of the code
> which is my point. I don't want an alien looking code in the mids of very uniform
> bunch. And I don't want distracting information, I want the essence stated clearly.
> I don't write assembly and I don't right computer language, I write English (conforming
> to computer logic).
> 
> > IOW: Just learn the meaning of 'pointer to __be32'.
> > 
> 
> What? I lost you, I don't understand what you mean?

I mean that the fundamental type of XDR is a __be32. We are using that
fundamental type in standard C code.
The fundamental Linux function for converting from a u32 to a __be32 is
cpu_to_be32(). It doesn't need a new wrapper, and neither does
be32_to_cpu().


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

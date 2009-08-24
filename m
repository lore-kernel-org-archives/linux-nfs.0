From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [pnfs] [PATCH RFC v2 0/21] nfs4xdr cleanup v2
Date: Mon, 24 Aug 2009 07:56:47 -0400
Message-ID: <1251115007.6325.9.camel@heimdal.trondhjem.org>
References: <4A8571E2.8020800@panasas.com>  <4A89338D.1040207@panasas.com>
	 <1250513254.8475.20.camel@heimdal.trondhjem.org>
	 <4A896125.2040506@panasas.com>
	 <1250527692.20012.26.camel@heimdal.trondhjem.org>
	 <4A9240C7.5090307@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63421 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751984AbZHXL5D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2009 07:57:03 -0400
In-Reply-To: <4A9240C7.5090307@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-08-24 at 10:27 +0300, Boaz Harrosh wrote:
> OK I used the new stuff by now, and I'm happy with everything
> but the above. I *absolutely* insist on this changing to:

Feel quite free to insist, but the patch isn't going in.

> 	p = xdr_encode_word(p, foo);
> and 
> 	p = xdr_decode_word(p, &foo);
> 
> [xdr_{encode,decode}_word is defined differently but is only used in a couple
>  of sunrpc files, the change of these places shall be added to this cleanup]
> 
> I have checked this version of the definition:
>  static inline __be32 *
>  xdr_encode_word(__be32 *p, __u32 val)
>  {
> 	*p++ = cpu_to_be32(val);
> 	return p;
>  }
> 
>  static inline __be32 *
>  xdr_decode_word(__be32 *p, __u32 *valp)
>  {
> 	*valp = be32_to_cpu(*p++);
> 	return p;
>  }
> 
> under assembly with gcc -O2 and it gives the exact same result as the open code,
> so I do not see what can be said against it?

It is unnecessary, it looks ugly, the latter form takes 2 pointers and
hides an assignment, it does an unconditional pointer increment.

IOW: Just learn the meaning of 'pointer to __be32'.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

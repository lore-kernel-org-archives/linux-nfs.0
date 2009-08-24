From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [pnfs] [PATCH RFC v2 0/21] nfs4xdr cleanup v2
Date: Mon, 24 Aug 2009 15:54:52 -0400
Message-ID: <1251143692.6325.348.camel@heimdal.trondhjem.org>
References: <4A8571E2.8020800@panasas.com>  <4A89338D.1040207@panasas.com>
	 <1250513254.8475.20.camel@heimdal.trondhjem.org>
	 <4A896125.2040506@panasas.com>
	 <1250527692.20012.26.camel@heimdal.trondhjem.org>
	 <4A9240C7.5090307@panasas.com>
	 <7BFE58E2-2621-48A2-885B-8F14F75441B2@oracle.com>
	 <1251133443.6325.260.camel@heimdal.trondhjem.org>
	 <254E8145-8E63-446D-B26C-BA5D0956A319@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Boaz Harrosh <bharrosh@panasas.com>,
	Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48257 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753364AbZHXT5J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2009 15:57:09 -0400
In-Reply-To: <254E8145-8E63-446D-B26C-BA5D0956A319@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-08-24 at 14:45 -0400, Chuck Lever wrote:
> On Aug 24, 2009, at 1:04 PM, Trond Myklebust wrote:
> > On Mon, 2009-08-24 at 09:45 -0400, Chuck Lever wrote:
> >> On Aug 24, 2009, at 3:27 AM, Boaz Harrosh wrote:
> >>> I have checked this version of the definition:
> >>> static inline __be32 *
> >>> xdr_encode_word(__be32 *p, __u32 val)
> >>> {
> >>> 	*p++ = cpu_to_be32(val);
> >>> 	return p;
> >>> }
> >>>
> >>> static inline __be32 *
> >>> xdr_decode_word(__be32 *p, __u32 *valp)
> >>> {
> >>> 	*valp = be32_to_cpu(*p++);
> >>> 	return p;
> >>> }
> >>>
> >>> under assembly with gcc -O2 and it gives the exact same result as
> >>> the open code,
> >>> so I do not see what can be said against it?
> >>
> >> In addition to being consistent with xdr_{encode,decode}_hyper, this
> >> adds appropriate static data type checking, which we want.
> >
> > OK. Let's examine that assertion:
> >
> > AFAICS, xdr_encode_word() doesn't add any typechecking that wasn't
> > already being performed with *p++=cpu_to_be32(foo). I call  
> > "bullshit" on
> > that...
> 
> I'm really really not interested in an argument about this, I was  
> merely expressing my opinion.
> 
> cpu_to_be32() does forced type casting, not static type checking.   
> Type casting in fact buries type mismatches, as you have pointed out  
> to me many times.

...and the proposed xdr_encode_word() does... (drumroll) .... forced
type casting of the u32 argument. No extra type checking.

> > xdr_decode_word() does indeed force you to use a pointer to __u32
> > argument. So if you actually wanted to decode say a signed integer,  
> > and
> > store it in a long you will need xdr_decode_int(). How does that help
> > us?
> 
> By making it explicit at the call site what is going on, instead of  
> allowing implicit type casting to cause problems down the road.
> 
> > Do we care about type checking storage of u32 into unsigned long? No
> 
> We might.  Unsigned long on 64-bit platforms is a 64 bit.  If someone  
> is careless with a pointer to a u64 (as I have been) this would  
> increase the probability of catching that during a build test.

So you assign a 32-bit value to a 64-bit container. Unless it involves
sign extension (and the protocol doesn't allow for that, see below),
then why is that problematic?

> > Do we care about type checking storage of u32 into unsigned int? No
> > Do we care about type checking storage of u32 into signed long or s64?
> > Maybe, so let's look at the protocol. Where does the protocol require
> > you to decode a signed value that might make use of this? The only
> > signed value I see in the protocol is for 'seconds', which is of type
> > int64. Does that justify introducing type checking on all those
> > be32_to_cpu() calls? Clearly, no.
> 
> Static type checking is prophylactic.  Basically we want to make it  
> harder to make stupid mistakes when writing the code.

I repeat my request for specific examples of coding errors that this
will catch. Bear in mind that we are coding to a particular protocol,
and that the entries in the structures in nfs_xdr.h are typed
accordingly.

> This is not  
> about run-time checking.

Who has said anything whatsoever about run time checking?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

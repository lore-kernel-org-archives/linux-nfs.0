From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [PATCH] Change prognum, versnum, minvers, and maxvers in
	progping to u_int32_t from u_long
Date: Wed, 22 Apr 2009 15:19:12 -0700
Message-ID: <1240438752.2246.20.camel@dyn9047022153>
References: <1240436748.2246.9.camel@dyn9047022153>
	 <AEAEC6BE-769B-4027-B427-041C65BB1EF8@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS List <linux-nfs@vger.kernel.org>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:53331 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754569AbZDVWNb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Apr 2009 18:13:31 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3MM30vv001229
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 18:03:00 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3MMDUvG175628
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 18:13:30 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3MMBhBN024264
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 18:11:43 -0400
In-Reply-To: <AEAEC6BE-769B-4027-B427-041C65BB1EF8@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-04-22 at 17:46 -0400, Chuck Lever wrote:
> On Apr 22, 2009, at 5:45 PM, Frank Filz wrote:
> > This fixes a problem where "rpcinfo -T transport host prognum" fails  
> > on a PPC64
> > because CLNT_CONTROL expects the version number to be a 32 bit  
> > quantity. u_long
> > probably works fine on little endian machines, but won't work on big  
> > endian
> > machines.
> 
> Hrm.  These variables are unsigned long pretty much everywhere in the  
> legacy RPC code.  And, isn't SPARC big endian?  Is the real problem  
> 32- v. 64- bit?

I at first though it would be a 64/32 bit problen, but now I think it
would still affect 32 bit, since unsigned long would still be a 64 bit
quantity, with the low order 32 bits being in the 5th through 8th bytes
on big endian, and therefore the 1st through 4th bytes which will be
accessed by casting a (void *) t (int *) would be 0.

> This might be fixed more generically by adding a type cast to  
> CLNT_CONTROL.

I did try a type cast at first, but it didn't work, though I might not
have done it right.

But look at these definitions from /usr/include/rpc/types.h:

/* This needs to be changed to uint32_t in the future */
typedef unsigned long rpcprog_t;
typedef unsigned long rpcvers_t;
typedef unsigned long rpcproc_t;
typedef unsigned long rpcprot_t;
typedef unsigned long rpcport_t;

Now look at the same definitions from /usr/include/tirpc/rpc/types.h:

typedef u_int32_t rpcprog_t;
typedef u_int32_t rpcvers_t;
typedef u_int32_t rpcproc_t;
typedef u_int32_t rpcprot_t;
typedef u_int32_t rpcport_t;

Actually, the patch probably should change the definitions to:

  rpcprog_t prognum;
  rpcvers_t versnum, minvers, maxvers;

(though internally, the CLNT_CONTROL is casting to u_int32_t, not
rpcvers_t or rpcprog_t).

It is curious though that in RFC 1833, there is this definition:

struct rpcb {
   unsigned long r_prog; /* program number */
   unsigned long r_vers; /* version number */
   string r_netid<>; /* network id */
   string r_addr<>; /* universal address */
   string r_owner<>; /* owner of this service */
};

But pretty much every where else, including the RPC protocol, prog and
vers are unsigned int...


> > Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
> > ---
> > src/rpcinfo.c |    2 +-
> > 1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/src/rpcinfo.c b/src/rpcinfo.c
> > index 0170f65..698f4ca 100644
> > --- a/src/rpcinfo.c
> > +++ b/src/rpcinfo.c
> > @@ -1591,7 +1591,7 @@ progping (netid, argc, argv)
> >   CLIENT *client;
> >   struct timeval to;
> >   enum clnt_stat rpc_stat;
> > -  u_long prognum, versnum, minvers, maxvers;
> > +  u_int32_t prognum, versnum, minvers, maxvers;
> >   struct rpc_err rpcerr;
> >   int failure = 0;
> >   struct netconfig *nconf;
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com


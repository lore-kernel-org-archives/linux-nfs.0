From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH kNFSd 1 of 4] Fixed possibly xdr parsing error if write size exceed 2^31
Date: Tue, 12 Jul 2005 03:42:43 -0300
Message-ID: <20050712064243.GA15802@dmt.cnet>
References: <20040816135256.9819.patches@notabene> <E1BwYdv-0002Zf-5L@notabene.cse.unsw.edu.au> <20050711095015.GA9650@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsO5c-0002zH-Fd
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 09:58:36 -0700
Received: from parcelfarce.linux.theplanet.co.uk ([195.92.249.252] ident=93)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DsO5b-000709-BZ
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 09:58:36 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050711095015.GA9650@suse.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi Olaf,

On Mon, Jul 11, 2005 at 11:50:16AM +0200, Olaf Kirch wrote:
> Hi all,
> 
> what happened to this patch? It never seems to have made it
> upstream.

I think it did, long ago:

nfs3xdr.c  	1.10  	CSets  	11 months 	neilb 	Fixed possibly xdr parsing error if write size exceed 2^31

> 
> Olaf
> 
> On Mon, Aug 16, 2004 at 01:58:43PM +1000, NeilBrown wrote:
> > 
> > xdr_argsize_check needs to cope with the possibility that the
> > pointer has wrapped and could be below buf->base.
> > 
> > Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>
> > 
> > ### Diffstat output
> >  ./fs/nfsd/nfs3xdr.c         |    2 +-
> >  ./include/linux/nfsd/xdr3.h |    2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
> > --- ./fs/nfsd/nfs3xdr.c~current~	2004-08-14 13:21:52.000000000 +1000
> > +++ ./fs/nfsd/nfs3xdr.c	2004-08-14 13:23:06.000000000 +1000
> > @@ -273,7 +273,7 @@ xdr_argsize_check(struct svc_rqst *rqstp
> >  {
> >  	struct svc_buf	*buf = &rqstp->rq_argbuf;
> >  
> > -	return p - buf->base <= buf->buflen;
> > +	return p >= buf->base && p <= buf->base + buf->buflen ;
> >  }
> >  
> >  static inline int
> > 
> > diff ./include/linux/nfsd/xdr3.h~current~ ./include/linux/nfsd/xdr3.h
> > --- ./include/linux/nfsd/xdr3.h~current~	2004-08-14 13:17:07.000000000 +1000
> > +++ ./include/linux/nfsd/xdr3.h	2004-08-16 09:48:43.000000000 +1000
> > @@ -41,7 +41,7 @@ struct nfsd3_writeargs {
> >  	__u32			count;
> >  	int			stable;
> >  	__u8 *			data;
> > -	int			len;
> > +	__u32			len;
> >  };
> >  
> >  struct nfsd3_createargs {


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

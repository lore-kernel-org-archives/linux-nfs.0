From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/5] nfsd41: bound forechannel drc size by memory usage
Date: Fri, 28 Aug 2009 16:56:53 -0400
Message-ID: <20090828205653.GC2462@fieldses.org>
References: <1251389264-3009-1-git-send-email-andros@netapp.com> <1251389264-3009-2-git-send-email-andros@netapp.com> <1251389264-3009-3-git-send-email-andros@netapp.com> <20090828204115.GB2462@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56206 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753182AbZH1U4v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Aug 2009 16:56:51 -0400
In-Reply-To: <20090828204115.GB2462@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 28, 2009 at 04:41:16PM -0400, bfields wrote:
> Looks basically fine, but there are a few nitpicky problems:
> 
> On Thu, Aug 27, 2009 at 12:07:41PM -0400, andros@netapp.com wrote:
> > From: Andy Adamson <andros@netapp.com>
> > 
> > By using the requested ca_maxresponsesize_cached * ca_maxresponses to bound
> > a forechannel drc request size, clients can tailor a session to usage.
> > 
> > For example, an I/O session (READ/WRITE only) can have a much smaller
> > ca_maxresponsesize_cached (for only WRITE compound responses) and a lot larger
> > ca_maxresponses to service a large in-flight data window.
> > 
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > ---
> >  fs/nfsd/nfs4state.c        |   60 +++++++++++++++++++++++++++++++------------
> >  include/linux/nfsd/state.h |    8 ++++-
> >  2 files changed, 49 insertions(+), 19 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index ddfd36f..a691139 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -414,34 +414,60 @@ gen_sessionid(struct nfsd4_session *ses)
> >  }
> >  
> >  /*
> > - * Give the client the number of slots it requests bound by
> > - * NFSD_MAX_SLOTS_PER_SESSION and by nfsd_drc_max_mem.
> > + * 32 bytes of RPC header and 44 bytes of sequence operation response
> > + * not included in NFSD_SLOT_CACHE_SIZE
> > + * */
> > +#define NFSD_MIN_HDR_SEQ_SZ  (32 + 44)
> 
> I took a look at a trace and got 24 for the rpc header (xid through
> accept state), 12 for compound header (status, empty tag, opcount), and
> 44 for the sequence response (opcode through status flags), 80
> together--could you double check this?
> 
> > +
> > +/*
> > + * Give the client the number of ca_maxresponsesize_cached slots it requests
> > + * bounded by NFSD_SLOT_CACHE_SIZE, NFSD_MAX_MEM_PER_SESSION and by
> > + * nfsd_drc_max_mem. Do not allow more than NFSD_MAX_SLOTS_PER_SESSION.
> > + *
> > + * The ca_maxresponssize_cached definition includes the size
> > + * of the rpc header with the variable length security flavor credential
> > + * plus verifier (32 bytes with AUTH_SYS and NULL verifier)
> 
> Note there's no credential in the response, just a verifier.   My
> attempt at these two comments:
> 
> /*
>  * The protocol defines ca_maxresponssize_cached to include the size of
>  * the rpc header, but all we need to cache is the data starting after
>  * the end of the initial SEQUENCE operation--the rest we regenerate
>  * each time.  Therefore we can advertise a ca_maxresponssize_cached
>  * value that is the number of bytes in our cache plus a few additional
>  * bytes.  In order to stay on the safe side, and not promise more than
>  * we can cache, those additional bytes must be the minimum possible: 24
>  * bytes of rpc header (xid through accept state, with AUTH_NULL
>  * verifier), 12 for the compound header (with zero-length tag), and 44
>  * for the SEQUENCE op response:
>  */
> #define NFSD_MIN_HDR_SEQ_SZ  (24 + 12 + 44)
> 
> /*
>  * Give the client the number of ca_maxresponsesize_cached slots it
>  * requests, of size bounded by NFSD_SLOT_CACHE_SIZE,
>  * NFSD_MAX_MEM_PER_SESSION, and nfsd_drc_max_mem. Do not allow more
>  * than NFSD_MAX_SLOTS_PER_SESSION.
>  *
>  * If we run out of reserved DRC memory we should (up to a point)
>  * re-negotiate active sessions and reduce their slot usage to make
>  * rooom for new connections. For now we just fail the create session.
>  */
> 
> Does that look right?
> 
> > + * as well as the encoded SEQUENCE operation response (44 bytes)
> > + * which are not included in NFSD_SLOT_CACHE_SIZE.
> > + * We err on the side of being a bit small when AUTH_SYS/NULL verifier
> > + * is not used.
> >   *
> >   * If we run out of reserved DRC memory we should (up to a point) re-negotiate
> >   * active sessions and reduce their slot usage to make rooom for new
> >   * connections. For now we just fail the create session.
> >   */
> > -static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
> > +static int set_forechannel_drc_size(struct nfsd4_channel_attrs *fchan)
> >  {
> > -	int mem;
> > +	int mem, size = fchan->maxresp_cached - NFSD_MIN_HDR_SEQ_SZ;
> >  
> > -	if (fchan->maxreqs < 1)
> > +	if (fchan->maxreqs < 1 || size <= 0)
> >  		return nfserr_inval;
> 
> Is it really illegal for the client to request a maxresp_cached less than
> NFSD_MIN_HDR_SEQ_SIZE?  I think this should just be rounded up to zero.
> 
> Also watch out for overflow: if the client gives an extremely large
> value for maxresp_cached then we should round it down rather than doing
> arithmetic that might result in overflow.
> 
> Simplest might be to first round maxresp_cached up to
> NFSD_MIN_HDR_SEQ_SIZE, if it's less.  *Then* subtract
> NFSD_MIN_HDR_SEQ_SIZE.  Then round down to NFSD_SLOT_CACHE_SIZE, if it's
> too large.  And keep all of this signed.
> 
> > -	else if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
> > -		fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
> >  
> > -	mem = fchan->maxreqs * NFSD_SLOT_CACHE_SIZE;
> > +	if (size > NFSD_SLOT_CACHE_SIZE)
> > +		size = NFSD_SLOT_CACHE_SIZE;
> > +
> > +	/* bound the maxreqs by NFSD_MAX_MEM_PER_SESSION */
> > +	mem = fchan->maxreqs * size;
> > +	if (mem > NFSD_MAX_MEM_PER_SESSION) {
> > +		fchan->maxreqs = NFSD_MAX_MEM_PER_SESSION / size;
> > +		if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
> > +			fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
> > +		mem = fchan->maxreqs * size;
> > +	}
> >  
> >  	spin_lock(&nfsd_drc_lock);
> > -	if (mem + nfsd_drc_mem_used > nfsd_drc_max_mem)
> > -		mem = ((nfsd_drc_max_mem - nfsd_drc_mem_used) /
> > -				NFSD_SLOT_CACHE_SIZE) * NFSD_SLOT_CACHE_SIZE;
> > +	/* bound the total session drc memory ussage */
> > +	if (mem + nfsd_drc_mem_used > nfsd_drc_max_mem) {
> > +		fchan->maxreqs = (nfsd_drc_max_mem - nfsd_drc_mem_used) / size;
> > +		mem = fchan->maxreqs * size;
> > +	}
> >  	nfsd_drc_mem_used += mem;
> >  	spin_unlock(&nfsd_drc_lock);
> >  
> > -	fchan->maxreqs = mem / NFSD_SLOT_CACHE_SIZE;
> >  	if (fchan->maxreqs == 0)
> > -		return nfserr_resource;
> > +		return nfserr_serverfault;
> 
> Remind me why serverfault and not resource here?

Whoops, OK, I see that one's answered later--it's not a legal error any
more.

--b.

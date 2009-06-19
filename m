From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 28/44] nfsd41: use the maximum operations per compound
	in nfsd4_compoundargs
Date: Thu, 18 Jun 2009 21:04:10 -0400
Message-ID: <20090619010410.GC16785@fieldses.org>
References: <1245115233-7725-1-git-send-email-bhalevy@panasas.com> <20090618221443.GH12234@fieldses.org> <20090619004936.GB19581@m3.macko.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org
To: Mike Mackovitch <macko-2kanFRK1NckAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44958 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbZFSBEJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 21:04:09 -0400
In-Reply-To: <20090619004936.GB19581-kyl61TxYs+X2fBVCVOL8/A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 18, 2009 at 05:49:36PM -0700, Mike Mackovitch wrote:
> On Thu, Jun 18, 2009 at 06:14:43PM -0400, J. Bruce Fields wrote:
> > On Tue, Jun 16, 2009 at 04:20:33AM +0300, Benny Halevy wrote:
> > > From: Andy Adamson <andros@netapp.com>
> > > 
> > > The size of the nfsd4_op array in nfsd4_compoundargs determines the
> > > supported maximum number of operations.
> > 
> > This is another one that is a clear straightfoward bugfix to existing
> > code, so please put it right up at the front of the patch series.
> > 
> > (ALso a comment that more clearly explains the problem would help, say,
> > like:
> > 
> > 	"We're returning NFSD_MAX_OPS_PER_COMPOUND = 16 to 4.1 clients,
> > 	but the limit the server actually enforces (in
> > 	nfsd4_decode_compound) is 8.  Fix the value of
> > 	NFSD_MAX_OPS_PER_COMPOUND to return the correct value to 4.1
> > 	clients."
> > 
> > )
> 
> Doesn't nfsd4_decode_compound() handle more ops by allocating
> a separate, larger array to hold them?:
> 
> >From http://lxr.linux.no/linux+v2.6.30/fs/nfsd/nfs4xdr.c :
> 
> 1424        if (argp->opcnt > 100)
> 1425                goto xdr_error;
> 1426
> 1427        if (argp->opcnt > ARRAY_SIZE(argp->iops)) {
> 1428                argp->ops = kmalloc(argp->opcnt * sizeof(*argp->ops), GFP_KERNEL);
> 1429                if (!argp->ops) {
> 1430                        argp->ops = argp->iops;
> 1431                        dprintk("nfsd: couldn't allocate room for COMPOUND\n");
> 1432                        goto xdr_error;
> 1433                }
> 1434        }
> 
> That looks to me like up to 100 ops are allowed.

Oops--I glanced at that code, saw the opcnt check, then turned my brain
off.  Thanks!  That patch wasn't in my published branch yet, so I've
removed it....

> As an NFS client implementer I wouldn't expect to generate a compound
> with anything near 100 ops.  However, I have recently composed a
> compound consisting of up to 12 ops (attempting to be efficient in
> some NFSv4.0 named attribute code).  And 12 is larger than 8.... so
> I'll probably be sad if Linux isn't going to be supporting that many
> ops in a compound.

OK.  I wanna know how you got up to 12, though! That's quite a compound.

--b.

> 
> Thanks
> --macko
> 
> > > Signed-off-by: Andy Adamson <andros@netapp.com>
> > > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > > ---
> > >  include/linux/nfsd/state.h |    3 +--
> > >  include/linux/nfsd/xdr4.h  |    2 +-
> > >  2 files changed, 2 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> > > index aea8137..093f165 100644
> > > --- a/include/linux/nfsd/state.h
> > > +++ b/include/linux/nfsd/state.h
> > > @@ -94,8 +94,7 @@ struct nfs4_cb_conn {
> > >  
> > >  #define NFSD_MAX_SLOTS_PER_SESSION	16
> > >  #define NFSD_SLOT_CACHE_SIZE		512
> > > -/* Maximum number of operations per session compound */
> > > -#define NFSD_MAX_OPS_PER_COMPOUND	16
> > > +#define NFSD_MAX_OPS_PER_COMPOUND	8
> > >  
> > >  struct nfsd4_slot {
> > >  	bool	sl_inuse;
> > > diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> > > index 84ac4bb..d99c8fe 100644
> > > --- a/include/linux/nfsd/xdr4.h
> > > +++ b/include/linux/nfsd/xdr4.h
> > > @@ -446,7 +446,7 @@ struct nfsd4_compoundargs {
> > >  	u32				minorversion;
> > >  	u32				opcnt;
> > >  	struct nfsd4_op			*ops;
> > > -	struct nfsd4_op			iops[8];
> > > +	struct nfsd4_op			iops[NFSD_MAX_OPS_PER_COMPOUND];
> > >  };
> > >  
> > >  struct nfsd4_compoundres {
> > > -- 
> > > 1.6.3
> > > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

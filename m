Return-Path: <smayhew@redhat.com>
Date: Wed, 13 Dec 2017 13:22:20 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
	bcodding redhat <bcodding@redhat.com>,
	"fsorenso@redhat.com" <fsorenso@redhat.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"dwysocha@redhat.com" <dwysocha@redhat.com>
Subject: Re: [PATCH] nfs/pnfs: fix nfs_direct_req ref leak when i/o falls
 back to the mds
Message-ID: <20171213182220.lrfbvkaj65fg6abk@tonberry.usersys.redhat.com>
References: <20171213161555.27993-1-smayhew@redhat.com>
 <1513186535.10540.8.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1513186535.10540.8.camel@primarydata.com>
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 13 Dec 2017, Trond Myklebust wrote:

> On Wed, 2017-12-13 at 11:15 -0500, Scott Mayhew wrote:
> > Currently when falling back to doing I/O through the MDS (via
> > pnfs_{read|write}_through_mds), the client frees the nfs_pgio_header
> > without releasing the reference taken on the dreq
> > via pnfs_generic_pg_{read|write}pages -> nfs_pgheader_init ->
> > nfs_direct_pgio_init.  It then takes another reference on the dreq
> > via
> > nfs_generic_pg_pgios -> nfs_pgheader_init -> nfs_direct_pgio_init and
> > as a result the requester will become stuck in inode_dio_wait.  Once
> > that happens, other processes accessing the inode will become stuck
> > as
> > well.
> > 
> > Moving the init_hdr call down to nfs_initiate_pgio ensures we take
> > the
> > reference on the dreq only once.
> > 
> > This can be reproduced (sometimes) by performing "storage failover
> > takeover" commands on NetApp filer while doing direct I/O from a
> > client.
> > 
> > This can also be reproduced using SystemTap to simulate a failure
> > while
> > doing direct I/O from a client (from Dave Wysochanski
> > <dwysocha@redhat.com>):
> > 
> > stap -v -g -e 'probe
> > module("nfs_layout_nfsv41_files").function("nfs4_fl_prepare_ds").retu
> > rn { $return=NULL; exit(); }'
> > 
> > Suggested-by: Benjamin Coddington <bcodding@redhat.com>
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> >  fs/nfs/pagelist.c | 6 +++---
> >  1 file changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> > index d0543e1..d478c19 100644
> > --- a/fs/nfs/pagelist.c
> > +++ b/fs/nfs/pagelist.c
> > @@ -54,9 +54,6 @@ void nfs_pgheader_init(struct nfs_pageio_descriptor
> > *desc,
> >  	hdr->dreq = desc->pg_dreq;
> >  	hdr->release = release;
> >  	hdr->completion_ops = desc->pg_completion_ops;
> > -	if (hdr->completion_ops->init_hdr)
> > -		hdr->completion_ops->init_hdr(hdr);
> > -
> >  	hdr->pgio_mirror_idx = desc->pg_mirror_idx;
> >  }
> >  EXPORT_SYMBOL_GPL(nfs_pgheader_init);
> > @@ -607,6 +604,9 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt,
> > struct nfs_pgio_header *hdr,
> >  	};
> >  	int ret = 0;
> >  
> > +	if (hdr->completion_ops->init_hdr)
> > +		hdr->completion_ops->init_hdr(hdr);
> > +
> >  	hdr->rw_ops->rw_initiate(hdr, &msg, rpc_ops,
> > &task_setup_data, how);
> >  
> >  	dprintk("NFS: initiated pgio call "
> 
> Won't this break as soon as we hit a call to nfs_pgio_error()? Also,
> what about block layout, which never calls nfs_initiate_pgio()?

Yes, it appears it would break both of those.  Sorry I missed that.

> 
> I'd prefer that we fix this in pnfs_read_through_mds() and
> pnfs_write_through_mds() by ensuring that those functions clean up
> correctly. Should they be calling hdr->completion_ops->completion()
> instead of calling hdr->release() directly?

We were wondering if that might be the case too.  I'll get to testing on
that right away.

Thanks,
Scott
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com

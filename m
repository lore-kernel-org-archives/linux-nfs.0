Return-Path: bfields@fieldses.org
Date: Thu, 6 Nov 2014 15:13:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Client never uses DATA_SYNC
Message-ID: <20141106201341.GD22638@fieldses.org>
References: <alpine.LRH.2.11.1411041036320.20279@sh-el6.eng.rdu2.redhat.com>
 <CAHQdGtSowoYZDUb6jBbj8Q0g6LeNVHmOCNBoZdDU8CgCZFpOXA@mail.gmail.com>
 <20141105085317.GA18658@infradead.org>
 <20141105144133.GA3139@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141105144133.GA3139@fieldses.org>
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 05, 2014 at 09:41:33AM -0500, J. Bruce Fields wrote:
> On Wed, Nov 05, 2014 at 12:53:17AM -0800, Christoph Hellwig wrote:
> > On Tue, Nov 04, 2014 at 03:38:28PM -0500, Trond Myklebust wrote:
> > > Hi Ben,
> > > 
> > > On Tue, Nov 4, 2014 at 10:47 AM, Benjamin Coddington
> > > <bcodding@redhat.com> wrote:
> > > > I have a customer that would like the client to use DATA_SYNC instead of
> > > > FILE_SYNC when writing a file with O_DSYNC.  It looks like the client will
> > > > only use FILE_SYNC since:
> > > >
> > > > 87ed5eb44ad9338b1617 NFS: Don't use DATA_SYNC writes
> > > > http://marc.info/?l=git-commits-head&m=131180398113265&w=2
> > > >
> > > > I've been unable to dig up any other discussion on this, so I think it
> > > > has just been an overlooked point until now.  I'm only starting to
> > > > figure out what would need to change for this, and I thought that while
> > > > I do that I'd ask the list if anyone thinks that serious implementation
> > > > issues might emerge if this were attempted.
> > > 
> > > I'm not aware of any servers that make a real distinction between
> > > FILE_SYNC and DATA_SYNC. Has anybody done any performance measurements
> > > to show that it is worth the effort?
> > 
> > For a fully allocated file the difference between fdatasync and fsync
> > or O_DSYNC / O_SYNC can make a difference, this is especially notiable
> > on data base workloads that do lots of small I/O on fully preallocated
> > files.
> > 
> > Implementing this difference for the Linux NFS server also seem fairly
> > trivial, patch attached.
> 
> Makes sense to me.--b.

Applying for 3.19.--b.

> 
> > 
> 
> > >From 61fee1aacf2f31b6fb1bb90d90f5e625994970f6 Mon Sep 17 00:00:00 2001
> > From: Christoph Hellwig <hch@lst.de>
> > Date: Wed, 5 Nov 2014 09:50:35 +0100
> > Subject: nfsd: implement DATA_SYNC4 support
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  fs/nfsd/nfs3proc.c |  4 ++--
> >  fs/nfsd/nfs4proc.c |  7 +++----
> >  fs/nfsd/nfsproc.c  |  7 ++-----
> >  fs/nfsd/vfs.c      | 14 +++++++-------
> >  fs/nfsd/vfs.h      |  3 ++-
> >  5 files changed, 16 insertions(+), 19 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> > index 12f2aab..cc9622f 100644
> > --- a/fs/nfsd/nfs3proc.c
> > +++ b/fs/nfsd/nfs3proc.c
> > @@ -191,12 +191,12 @@ nfsd3_proc_write(struct svc_rqst *rqstp, struct nfsd3_writeargs *argp,
> >  				argp->stable? " stable" : "");
> >  
> >  	fh_copy(&resp->fh, &argp->fh);
> > -	resp->committed = argp->stable;
> >  	nfserr = nfsd_write(rqstp, &resp->fh, NULL,
> >  				   argp->offset,
> >  				   rqstp->rq_vec, argp->vlen,
> >  				   &cnt,
> > -				   &resp->committed);
> > +				   argp->stable);
> > +	resp->committed = argp->stable;
> >  	resp->count = cnt;
> >  	RETURN_STATUS(nfserr);
> >  }
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index c4a2adc..b11fd3b 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -998,15 +998,14 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	}
> >  
> >  	cnt = write->wr_buflen;
> > -	write->wr_how_written = write->wr_stable_how;
> >  	gen_boot_verifier(&write->wr_verifier, SVC_NET(rqstp));
> >  
> >  	nvecs = fill_in_write_vector(rqstp->rq_vec, write);
> >  	WARN_ON_ONCE(nvecs > ARRAY_SIZE(rqstp->rq_vec));
> >  
> > -	status =  nfsd_write(rqstp, &cstate->current_fh, filp,
> > -			     write->wr_offset, rqstp->rq_vec, nvecs,
> > -			     &cnt, &write->wr_how_written);
> > +	status = nfsd_write(rqstp, &cstate->current_fh, filp, write->wr_offset,
> > +			    rqstp->rq_vec, nvecs, &cnt, write->wr_stable_how);
> > +	write->wr_how_written = write->wr_stable_how;
> >  	if (filp)
> >  		fput(filp);
> >  
> > diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> > index b868073..90caa00 100644
> > --- a/fs/nfsd/nfsproc.c
> > +++ b/fs/nfsd/nfsproc.c
> > @@ -158,7 +158,6 @@ nfsd_proc_write(struct svc_rqst *rqstp, struct nfsd_writeargs *argp,
> >  					struct nfsd_attrstat  *resp)
> >  {
> >  	__be32	nfserr;
> > -	int	stable = 1;
> >  	unsigned long cnt = argp->len;
> >  
> >  	dprintk("nfsd: WRITE    %s %d bytes at %d\n",
> > @@ -166,10 +165,8 @@ nfsd_proc_write(struct svc_rqst *rqstp, struct nfsd_writeargs *argp,
> >  		argp->len, argp->offset);
> >  
> >  	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh), NULL,
> > -				   argp->offset,
> > -				   rqstp->rq_vec, argp->vlen,
> > -			           &cnt,
> > -				   &stable);
> > +			    argp->offset, rqstp->rq_vec, argp->vlen,
> > +			    &cnt, NFS_FILE_SYNC);
> >  	return nfsd_return_attrs(nfserr, resp);
> >  }
> >  
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index 989129e..2ea8ff6 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -927,7 +927,7 @@ static int wait_for_concurrent_writes(struct file *file)
> >  static __be32
> >  nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
> >  				loff_t offset, struct kvec *vec, int vlen,
> > -				unsigned long *cnt, int *stablep)
> > +				unsigned long *cnt, enum nfs3_stable_how stable)
> >  {
> >  	struct svc_export	*exp;
> >  	struct dentry		*dentry;
> > @@ -935,7 +935,6 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
> >  	mm_segment_t		oldfs;
> >  	__be32			err = 0;
> >  	int			host_err;
> > -	int			stable = *stablep;
> >  	int			use_wgather;
> >  	loff_t			pos = offset;
> >  	unsigned int		pflags = current->flags;
> > @@ -956,7 +955,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
> >  	use_wgather = (rqstp->rq_vers == 2) && EX_WGATHER(exp);
> >  
> >  	if (!EX_ISSYNC(exp))
> > -		stable = 0;
> > +		stable = NFS_UNSTABLE;
> >  
> >  	/* Write the data. */
> >  	oldfs = get_fs(); set_fs(KERNEL_DS);
> > @@ -972,7 +971,8 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
> >  		if (use_wgather)
> >  			host_err = wait_for_concurrent_writes(file);
> >  		else
> > -			host_err = vfs_fsync_range(file, offset, offset+*cnt, 0);
> > +			host_err = vfs_fsync_range(file, offset, offset+*cnt,
> > +						   stable == NFS_DATA_SYNC);
> >  	}
> >  
> >  out_nfserr:
> > @@ -1051,7 +1051,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
> >  __be32
> >  nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
> >  		loff_t offset, struct kvec *vec, int vlen, unsigned long *cnt,
> > -		int *stablep)
> > +		enum nfs3_stable_how stable)
> >  {
> >  	__be32			err = 0;
> >  
> > @@ -1061,7 +1061,7 @@ nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
> >  		if (err)
> >  			goto out;
> >  		err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt,
> > -				stablep);
> > +				stable);
> >  	} else {
> >  		err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
> >  		if (err)
> > @@ -1069,7 +1069,7 @@ nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
> >  
> >  		if (cnt)
> >  			err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen,
> > -					     cnt, stablep);
> > +					     cnt, stable);
> >  		nfsd_close(file);
> >  	}
> >  out:
> > diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> > index c2ff3f1..3cb8e55 100644
> > --- a/fs/nfsd/vfs.h
> > +++ b/fs/nfsd/vfs.h
> > @@ -81,7 +81,8 @@ __be32		nfsd_readv(struct file *, loff_t, struct kvec *, int,
> >  __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
> >  				loff_t, struct kvec *, int, unsigned long *);
> >  __be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
> > -				loff_t, struct kvec *,int, unsigned long *, int *);
> > +				loff_t, struct kvec *,int, unsigned long *,
> > +				enum nfs3_stable_how);
> >  __be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
> >  				char *, int *);
> >  __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
> > -- 
> > 1.9.1
> > 
> 

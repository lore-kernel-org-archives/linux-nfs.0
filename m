Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47300 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751306AbaHOVfW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Aug 2014 17:35:22 -0400
Date: Fri, 15 Aug 2014 17:35:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 1/5 v3] NFSD: Remove duplicate initialization of file_lock
Message-ID: <20140815213519.GA11351@fieldses.org>
References: <53BAAAC5.9000106@gmail.com>
 <53E22EA5.70708@gmail.com>
 <20140809065112.700e0ecc@tlielax.poochiereds.net>
 <53E791F1.40802@gmail.com>
 <53ED4E2F.2010701@gmail.com>
 <20140815065741.42f18ec9@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140815065741.42f18ec9@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 15, 2014 at 06:57:41AM -0400, Jeff Layton wrote:
> On Fri, 15 Aug 2014 08:02:55 +0800
> Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
> > locks_alloc_lock() has initialize struct file_lock,
> > don't need re-initialize it by locks_init_lock().
> > 
> > v3: A new patch isn't exit in v2/v1.
> > 
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> > ---
> >  fs/nfsd/nfs4state.c | 6 ++----
> >  1 file changed, 2 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 2e80a59..98edf97 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3759,7 +3759,6 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
> >  	fl = locks_alloc_lock();
> >  	if (!fl)
> >  		return NULL;
> > -	locks_init_lock(fl);
> >  	fl->fl_lmops = &nfsd_lease_mng_ops;
> >  	fl->fl_flags = FL_DELEG;
> >  	fl->fl_type = flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
> > @@ -5210,7 +5209,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	}
> >  
> >  	fp = lock_stp->st_stid.sc_file;
> > -	locks_init_lock(file_lock);
> >  	switch (lock->lk_type) {
> >  		case NFS4_READ_LT:
> >  		case NFS4_READW_LT:
> > @@ -5354,7 +5352,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		status = nfserr_jukebox;
> >  		goto out;
> >  	}
> > -	locks_init_lock(file_lock);
> > +
> >  	switch (lockt->lt_type) {
> >  		case NFS4_READ_LT:
> >  		case NFS4_READW_LT:
> > @@ -5432,7 +5430,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		status = nfserr_jukebox;
> >  		goto fput;
> >  	}
> > -	locks_init_lock(file_lock);
> > +
> >  	file_lock->fl_type = F_UNLCK;
> >  	file_lock->fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
> >  	file_lock->fl_pid = current->tgid;
> 
> Bruce, since this is an nfsd patch, do you mind picking this one up?
> 
> Reviewed-by: Jeff Layton <jlayton@primarydata.com>

Yep, got it, thanks!

--b.

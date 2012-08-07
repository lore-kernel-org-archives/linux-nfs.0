Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753262Ab2HGPxI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 11:53:08 -0400
Date: Tue, 7 Aug 2012 11:53:01 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: trivial comment updates
Message-ID: <20120807115301.1350d865@tlielax.poochiereds.net>
In-Reply-To: <20120807152318.GB21022@fieldses.org>
References: <1344265227-22280-1-git-send-email-jlayton@redhat.com>
	<20120807152318.GB21022@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 7 Aug 2012 11:23:19 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Aug 06, 2012 at 11:00:27AM -0400, Jeff Layton wrote:
> > locks.c doesn't use the BKL anymore and there is no fi_perfile field.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfsd/nfs4state.c | 6 +-----
> >  fs/nfsd/state.h     | 6 +-----
> >  2 files changed, 2 insertions(+), 10 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index cc894ed..d8a7ddf 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -4151,11 +4151,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	file_lock.fl_end = last_byte_offset(lock->lk_offset, lock->lk_length);
> >  	nfs4_transform_lock_offset(&file_lock);
> >  
> > -	/*
> > -	* Try to lock the file in the VFS.
> > -	* Note: locks.c uses the BKL to protect the inode's lock list.
> > -	*/
> > -
> > +	/* Try to lock the file in the VFS. */
> 
> Thanks, applying, but: mind if I just drop this comment entirely?  "Try
> to lock the file in the VFS" doesn't add much to "vfs_lock_file()".
> 
> --b.
> 

Totally fine with me.

> >  	err = vfs_lock_file(filp, F_SETLK, &file_lock, &conflock);
> >  	switch (-err) {
> >  	case 0: /* success! */
> > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > index e617314..cce91c8 100644
> > --- a/fs/nfsd/state.h
> > +++ b/fs/nfsd/state.h
> > @@ -374,11 +374,7 @@ static inline struct nfs4_lockowner * lockowner(struct nfs4_stateowner *so)
> >  	return container_of(so, struct nfs4_lockowner, lo_owner);
> >  }
> >  
> > -/*
> > -*  nfs4_file: a file opened by some number of (open) nfs4_stateowners.
> > -*    o fi_perfile list is used to search for conflicting 
> > -*      share_acces, share_deny on the file.
> > -*/
> > +/* nfs4_file: a file opened by some number of (open) nfs4_stateowners. */
> >  struct nfs4_file {
> >  	atomic_t		fi_ref;
> >  	struct list_head        fi_hash;    /* hash by "struct inode *" */
> > -- 
> > 1.7.11.2
> > 


-- 
Jeff Layton <jlayton@redhat.com>

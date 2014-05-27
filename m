Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61099 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711AbaE0P27 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2014 11:28:59 -0400
Date: Tue, 27 May 2014 11:28:57 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd4: remove lockowner when removing lock stateid
Message-ID: <20140527152857.GB2312@pad.redhat.com>
References: <1400688325-5345-1-git-send-email-bfields@redhat.com>
 <1400688325-5345-2-git-send-email-bfields@redhat.com>
 <20140527085007.7beb02ec@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140527085007.7beb02ec@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 27, 2014 at 08:50:07AM -0400, Jeff Layton wrote:
> On Wed, 21 May 2014 12:05:24 -0400
> "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > The nfsv4 state code has always assumed a one-to-one correspondance
> > between lock stateid's and lockowners even if it appears not to in some
> > places.
> > 
> > We may actually change that, but for now when FREE_STATEID releases a
> > lock stateid it also needs to release the parent lockowner.
> > 
> > Symptoms were a subsequent LOCK crashing in find_lockowner_str when it
> > calls same_lockowner_ino on a lockowner that unexpectedly has an empty
> > so_stateids list.
> > 
> > Cc: stable@vger.kernel.org
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/nfs4state.c | 11 +++++++++--
> >  1 file changed, 9 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 32b699b..89e4240 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3717,9 +3717,16 @@ out:
> >  static __be32
> >  nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
> >  {
> > -	if (check_for_locks(stp->st_file, lockowner(stp->st_stateowner)))
> > +	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
> > +
> > +	if (check_for_locks(stp->st_file, lo))
> >  		return nfserr_locks_held;
> > -	release_lock_stateid(stp);
> > +	/*
> > +	 * Currently there's a 1-1 lock stateid<->lockowner
> > +	 * correspondance, and we have to delete the lockowner when we
> > +	 * delete the lock stateid:
> > +	 */
> > +	unhash_lockowner(lo);
> 
> Shouldn't this be release_lockowner(lo) ? If not, what's going to free
> the lockowner afterward?

Yes, thank you!  I'll probably send along the following soon....

--b.

commit bc0336505f20
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue May 27 11:14:26 2014 -0400

    nfsd4: fix FREE_STATEID lockowner leak
    
    27b11428b7de ("nfsd4: remove lockowner when removing lock stateid")
    introduced a memory leak.
    
    Reported-by: Jeff Layton <jeff.layton@primarydata.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9a77a5a21557..6134ee283798 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3726,7 +3726,7 @@ nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 	 * correspondance, and we have to delete the lockowner when we
 	 * delete the lock stateid:
 	 */
-	unhash_lockowner(lo);
+	release_lockowner(lo);
 	return nfs_ok;
 }
 

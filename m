Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53654 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750861AbeARB6v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Jan 2018 20:58:51 -0500
Date: Wed, 17 Jan 2018 20:58:51 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Detect unhashed stids in nfsd4_verify_open_stid()
Message-ID: <20180118015851.GC2906@fieldses.org>
References: <20180112224230.129322-1-trond.myklebust@primarydata.com>
 <3D728866-A30E-420D-9001-F4B212432C36@oracle.com>
 <20180117213057.GA1441@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180117213057.GA1441@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 17, 2018 at 04:30:57PM -0500, bfields wrote:
> On Fri, Jan 12, 2018 at 09:15:46PM -0500, Chuck Lever wrote:
> > 
> > 
> > > On Jan 12, 2018, at 5:42 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > > 
> > > The state of the stid is guaranteed by 2 locks:
> > > - The nfs4_client 'cl_lock' spinlock
> > > - The nfs4_ol_stateid 'st_mutex' mutex
> > > 
> > > so it is quite possible for the stid to be unhashed after lookup,
> > > but before calling nfsd4_lock_ol_stateid(). So we do need to check
> > > for a zero value for 'sc_type' in nfsd4_verify_open_stid().
> > > 
> > > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > 
> > Three successful passes of the git regression suite on NFSv4.1
> > Three successful passes of xfstests on NFSv4.1
> > 
> > Tested-by: Chuck Lever <chuck.lever@oracle.com>
> 
> Thanks!  Applying.

Though the changelog doesn't make sense to me.  What does it mean for
the "state of the stid" to be "gauranteed by 2 locks"?

The following paragraph suggests that once we acquire st_mutex, sc_type
can no longer change, but that doesn't look right--e.g.
nfsd4_release_lockowner calls unhash-lock_stateid->nfs4_unhash_stid with
only the cl_lock held.

--b.

> 
> Then I think this makes a couple of "sc_type = NFS4_CLOSED_STID"'s
> superfluous.
> 
> --b.
> 
> commit 17693d95b3d3
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Wed Jan 17 16:25:59 2018 -0500
> 
>     nfsd4: don't set lock stateid's sc_type to CLOSED
>     
>     There's no point I can see to
>     
>             stp->st_stid.sc_type = NFS4_CLOSED_STID;
>     
>     given release_lock_stateid immediately sets sc_type to 0.
>     
>     That set of sc_type to 0 should be enough to prevent it being used where
>     we don't want it to be; NFS4_CLOSED_STID should only be needed for
>     actual open stateid's that are actually closed.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 5a75135f5f53..150521c9671b 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -5183,7 +5183,6 @@ nfsd4_free_lock_stateid(stateid_t *stateid, struct nfs4_stid *s)
>  			    lockowner(stp->st_stateowner)))
>  		goto out;
>  
> -	stp->st_stid.sc_type = NFS4_CLOSED_STID;
>  	release_lock_stateid(stp);
>  	ret = nfs_ok;
>  
> @@ -6079,10 +6078,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		 * If this is a new, never-before-used stateid, and we are
>  		 * returning an error, then just go ahead and release it.
>  		 */
> -		if (status && new) {
> -			lock_stp->st_stid.sc_type = NFS4_CLOSED_STID;
> +		if (status && new)
>  			release_lock_stateid(lock_stp);
> -		}
>  
>  		mutex_unlock(&lock_stp->st_mutex);
>  

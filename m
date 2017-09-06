Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41895 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753896AbdIFQDo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Sep 2017 12:03:44 -0400
Date: Wed, 6 Sep 2017 12:03:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
Message-ID: <20170906160342.GB28077@parsley.fieldses.org>
References: <20170829214026.GI8822@parsley.fieldses.org>
 <8760d5hol3.fsf@notabene.neil.brown.name>
 <20170830170938.GC24373@parsley.fieldses.org>
 <87wp5kfxi3.fsf@notabene.neil.brown.name>
 <20170831190531.GA8223@parsley.fieldses.org>
 <873787fhc5.fsf@notabene.neil.brown.name>
 <20170901161809.GA22140@parsley.fieldses.org>
 <871snndq04.fsf@notabene.neil.brown.name>
 <20170905195619.GB17828@parsley.fieldses.org>
 <877excde18.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <877excde18.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 06, 2017 at 07:35:47AM +1000, NeilBrown wrote:
> On Tue, Sep 05 2017, J. Bruce Fields wrote:
> 
> > On Mon, Sep 04, 2017 at 02:52:43PM +1000, NeilBrown wrote:
> >> and add some wait queue somewhere
> >> so the breaker could wait for a delegation to be returned.
> >
> > In the nfsd case we're just returning to the client immediately, so
> > that's not really necessary, though maybe it could be useful.
> 
> Ah yes, so we do.  I inverted the logic in my mind.  That makes it easier.

(Minor derail: it might be worth waiting briefly before returning
NFS4ERR_DELAY.

It would be easy enough to implement, the hard part would be testing
whether it helped.  I think the initial client retry time is 100ms
(NFS4_POLL_RETRY_MIN), so it'd have to beat that frequently enough.)

> Thanks.  Below is a patch that does compile but is probably wrong is
> various ways and definitely needs cleanliness work at least.  I provide
> it just to be more concrete about my thinking.

Gah, I hate having to patch every notify_change caller.  But maybe I
should get over that, the resulting logic is simpler.  Anyway, stripping
away all those callers:

Right, the advantage is that this makes checking for conflicts simple
and obvious:

> diff --git a/fs/locks.c b/fs/locks.c
> index afefeb4ad6de..231d93bfbdc1 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1408,6 +1408,8 @@ static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
>  		return false;
>  	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE))
>  		return false;
> +	if (breaker->fl_owner && breaker->fl_owner == lease->fl_owner)
> +		return false;
>  	return locks_conflict(breaker, lease);
>  }

notify_change, vfs_unlink, etc., all get a new argument:

> + * @owner:	allow delegation to this owner to remain

And, right, we need a way to lookup nfs4_file by inode:

> +static struct nfs4_file *
> +find_deleg_file_by_inode(struct inode *ino)

(ignoring how we do it for now).

>  /* 
>   * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
>   * a mount point.
> @@ -455,7 +458,8 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  			.ia_size	= iap->ia_size,
>  		};
>  
> -		host_err = notify_change(dentry, &size_attr, NULL);
> +		host_err = nfsd_conflicting_leases(dentry, rqstp);
> +		host_err = host_err ?: notify_change(dentry, &size_attr, nfsd_deleg_owner, NULL);

And then you recall nfsd delegations and delegations held by
(hypothetical) non-nfsd users separately, OK (also ignoring how).

There are no such users currently, so nfsd could just pass NULL.

--b.

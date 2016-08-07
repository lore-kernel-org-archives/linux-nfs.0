Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35750 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbcHGCBT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2016 22:01:19 -0400
Received: by mail-qk0-f195.google.com with SMTP id q62so26466765qkf.2
        for <linux-nfs@vger.kernel.org>; Sat, 06 Aug 2016 19:01:19 -0700 (PDT)
Message-ID: <1470535273.27316.7.camel@poochiereds.net>
Subject: Re: [PATCH v1] nfsd: Fix race between FREE_STATEID and LOCK
From: Jeff Layton <jlayton@poochiereds.net>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Date: Sat, 06 Aug 2016 22:01:13 -0400
In-Reply-To: <20160806022349.3381.8042.stgit@klimt.1015granger.net>
References: <20160806022349.3381.8042.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-08-05 at 22:26 -0400, Chuck Lever wrote:
> Using LTP's nfslock01 test, one of our internal testers found that
> the Linux client can send a LOCK and a FREE_STATEID request at the
> same time. The LOCK uses the same lockowner as the stateid sent in
> the FREE_STATEID request.
> 
> The outcome is:
> 
> Frame 115025 C FREE_STATEID stateid 2/A
> Frame 115026 C LOCK offset 672128 len 64
> Frame 115029 R FREE_STATEID NFS4_OK
> Frame 115030 R LOCK stateid 3/A
> Frame 115034 C WRITE stateid 0/A offset 672128 len 64
> Frame 115038 R WRITE NFS4ERR_BAD_STATEID
> 
> In other words, the server returns stateid A in the LOCK reply, but
> it has already released it. Subsequent uses of the stateid fail.
> 
> To address this, protect the logic in nfsd4_free_stateid with the
> st_mutex. This should guarantee that only one of two outcomes
> occurs: either LOCK returns a fresh valid stateid, or FREE_STATEID
> returns NFS4ERR_LOCKS_HELD.
> 
> > Reported-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> > Fix-suggested-by: Jeff Layton <jlayton@redhat.com>
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Before I pass this along to Alexey for testing, I'd appreciate some
> review of the proposed fix.
> 
> 
>  fs/nfsd/nfs4state.c |   18 +++++++++++++-----
>  1 file changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index b921123..a9e0606 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4911,16 +4911,24 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		ret = nfserr_locks_held;
> >  		break;
> >  	case NFS4_LOCK_STID:
> > -		ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
> > -		if (ret)
> > -			break;
> > > +		spin_unlock(&cl->cl_lock);

Once you drop the spinlock, you don't hold a reference to the stateid
anymore. You'll want to bump the refcount and then put the extra
reference when you're done.

> > >  		stp = openlockstateid(s);
> > +		mutex_lock(&stp->st_mutex);
> > +		ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
> > +		if (ret) {
> > +			mutex_unlock(&stp->st_mutex);
> > +			goto out;
> > +		}
> >  		ret = nfserr_locks_held;
> >  		if (check_for_locks(stp->st_stid.sc_file,
> > -				    lockowner(stp->st_stateowner)))
> > -			break;
> > +				    lockowner(stp->st_stateowner))) {
> > +			mutex_unlock(&stp->st_mutex);
> > +			goto out;
> > +		}
> > +		spin_lock(&cl->cl_lock);
> >  		WARN_ON(!unhash_lock_stateid(stp));
> > >  		spin_unlock(&cl->cl_lock);

Now that you're dropping the spinlock, it could be unhashed before you
take it again. Probably should convert this and the following put to a
release_lock_stateid call.

> > > +		mutex_unlock(&stp->st_mutex);
> >  		nfs4_put_stid(s);
> >  		ret = nfs_ok;
> >  		goto out;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jeff Layton <jlayton@poochiereds.net>

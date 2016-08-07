Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36074 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbcHGSRS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Aug 2016 14:17:18 -0400
Received: by mail-qk0-f193.google.com with SMTP id x185so11803909qkc.3
        for <linux-nfs@vger.kernel.org>; Sun, 07 Aug 2016 11:17:18 -0700 (PDT)
Message-ID: <1470593833.2975.6.camel@poochiereds.net>
Subject: Re: [PATCH v1] nfsd: Fix race between FREE_STATEID and LOCK
From: Jeff Layton <jlayton@poochiereds.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Sun, 07 Aug 2016 14:17:13 -0400
In-Reply-To: <FE29E29F-A7C3-4649-975B-AAD8CADFCB55@oracle.com>
References: <20160806022349.3381.8042.stgit@klimt.1015granger.net>
	 <1470535273.27316.7.camel@poochiereds.net>
	 <FE29E29F-A7C3-4649-975B-AAD8CADFCB55@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2016-08-07 at 12:18 -0400, Chuck Lever wrote:
> Hi Jeff-
> 
> Thanks for your comments. Responses below:
> 
> 
> > 
> > On Aug 6, 2016, at 10:01 PM, Jeff Layton <jlayton@poochiereds.net>
> > wrote:
> > 
> > On Fri, 2016-08-05 at 22:26 -0400, Chuck Lever wrote:
> > > 
> > > Using LTP's nfslock01 test, one of our internal testers found
> > > that
> > > the Linux client can send a LOCK and a FREE_STATEID request at
> > > the
> > > same time. The LOCK uses the same lockowner as the stateid sent
> > > in
> > > the FREE_STATEID request.
> > > 
> > > The outcome is:
> > > 
> > > Frame 115025 C FREE_STATEID stateid 2/A
> > > Frame 115026 C LOCK offset 672128 len 64
> > > Frame 115029 R FREE_STATEID NFS4_OK
> > > Frame 115030 R LOCK stateid 3/A
> > > Frame 115034 C WRITE stateid 0/A offset 672128 len 64
> > > Frame 115038 R WRITE NFS4ERR_BAD_STATEID
> > > 
> > > In other words, the server returns stateid A in the LOCK reply,
> > > but
> > > it has already released it. Subsequent uses of the stateid fail.
> > > 
> > > To address this, protect the logic in nfsd4_free_stateid with the
> > > st_mutex. This should guarantee that only one of two outcomes
> > > occurs: either LOCK returns a fresh valid stateid, or
> > > FREE_STATEID
> > > returns NFS4ERR_LOCKS_HELD.
> > > 
> > > > 
> > > > Reported-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> > > > Fix-suggested-by: Jeff Layton <jlayton@redhat.com>
> > > > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > > ---
> > > 
> > > Before I pass this along to Alexey for testing, I'd appreciate
> > > some
> > > review of the proposed fix.
> > > 
> > > 
> > >  fs/nfsd/nfs4state.c |   18 +++++++++++++-----
> > >  1 file changed, 13 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > > index b921123..a9e0606 100644
> > > --- a/fs/nfsd/nfs4state.c
> > > +++ b/fs/nfsd/nfs4state.c
> > > @@ -4911,16 +4911,24 @@ nfsd4_free_stateid(struct svc_rqst
> > > *rqstp, struct nfsd4_compound_state *cstate,
> > > > 
> > > >  		ret = nfserr_locks_held;
> > > >  		break;
> > > >  	case NFS4_LOCK_STID:
> > > > -		ret = check_stateid_generation(stateid, &s-
> > > > >sc_stateid, 1);
> > > > -		if (ret)
> > > > -			break;
> > > > > 
> > > > > +		spin_unlock(&cl->cl_lock);
> > 
> > Once you drop the spinlock, you don't hold a reference to the
> > stateid
> > anymore. You'll want to bump the refcount and then put the extra
> > reference when you're done.
> 
> Ooops. find_stateid_by_type does bump the reference count,
> but indeed, find_stateid_locked does not. I can add
> 
>    atomic_inc(&s->sc_count);
> 
> here, and do something about putting sc_count in the exit
> paths below.
> 
> 

Yes. Just call nfs4_put_stid once you're done and that will put the
reference (and start freeing the stateid if it was the last one).

> > 
> > 
> > > 
> > > > 
> > > > > 
> > > > >  		stp = openlockstateid(s);
> > > > +		mutex_lock(&stp->st_mutex);
> > > > +		ret = check_stateid_generation(stateid, &s-
> > > > >sc_stateid, 1);
> > > > +		if (ret) {
> > > > +			mutex_unlock(&stp->st_mutex);
> > > > +			goto out;
> > > > +		}
> > > >  		ret = nfserr_locks_held;
> > > >  		if (check_for_locks(stp->st_stid.sc_file,
> > > > -				    lockowner(stp-
> > > > >st_stateowner)))
> > > > -			break;
> > > > +				    lockowner(stp-
> > > > >st_stateowner))) {
> > > > +			mutex_unlock(&stp->st_mutex);
> > > > +			goto out;
> > > > +		}
> > > > +		spin_lock(&cl->cl_lock);
> > > >  		WARN_ON(!unhash_lock_stateid(stp));
> > > > > 
> > > > >  		spin_unlock(&cl->cl_lock);
> > 
> > Now that you're dropping the spinlock, it could be unhashed before
> > you
> > take it again. Probably should convert this and the following put
> > to a
> > release_lock_stateid call.
> 
> Something like:
> 
>           goto out;
>      }
> 
>      release_lock_stateid
>           spin_lock(cl_lock)
>           unhash
>           spin_unlock(cl_lock)
>           maybe put_stid (now called while st_mutex is still held)
> 
>      mutex_unlock
>      put_stid (since now an extra reference count is taken above)
> 

release_lock_stateid will unhash it and put the hashtable reference if
it did the unhashing. So assuming you take the reference above while
still holding the spinlock:

	release_lock_stateid(); /* unhash and release hashtable reference */
	mutex_unlock(); /* unlock the stateid */
	nfs4_put_stid(); /* put the reference you acquired before dropping the spinlock */


> I guess we decided the ordering of mutex_unlock and
> put_stid ultimately doesn't matter.
> 

You definitely want to mutex_unlock before you put the reference you're
taking in this function. Otherwise you have no guarantee that the
pointer will still be good...

> 
> > 
> > > 
> > > > 
> > > > > 
> > > > > +		mutex_unlock(&stp->st_mutex);
> > > >  		nfs4_put_stid(s);
> > > >  		ret = nfs_ok;
> > > >  		goto out;
> 
> 
> --
> Chuck Lever
> 
> 
> 

-- 
Jeff Layton <jlayton@poochiereds.net>

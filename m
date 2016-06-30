Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40363 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119AbcF3QVX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jun 2016 12:21:23 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] nfsd: Close race between nfsd4_release_lockowner and nfsd4_lock
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1467303443.7421.1.camel@redhat.com>
Date: Thu, 30 Jun 2016 12:20:28 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6010058D-F107-41C5-AFA4-75E25E37935C@oracle.com>
References: <20160630160659.19405.46852.stgit@manet.1015granger.net> <1467303443.7421.1.camel@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 30, 2016, at 12:17 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> On Thu, 2016-06-30 at 12:12 -0400, Chuck Lever wrote:
>> nfsd4_release_lockowner finds a lock owner that has no lock state,
>> and drops cl_lock. Then release_lockowner picks up cl_lock and
>> unhashes the lock owner.
>> 
>> During the window where cl_lock is dropped, I don't see anything
>> preventing a concurrent nfsd4_lock from finding that same lock owner
>> and adding lock state to it.
>> 
>> Move release_lockowner() into nfsd4_release_lockowner and hang onto
>> the cl_lock until after the lock owner's state has been unhashed.
>> 
>> Fixes: 2c41beb0e5cf ("nfsd: reduce cl_lock thrashing in ... ")
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>  fs/nfsd/nfs4state.c |   40 +++++++++++++++++-----------------------
>>  1 file changed, 17 insertions(+), 23 deletions(-)
>> 
>> Hey Jeff-
>> 
>> Wondering what your thoughts about this are. I noticed a possible
>> race while looking at another bug. It's untested.
>> 
>> 
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 70d0b9b..b921123 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1200,27 +1200,6 @@ free_ol_stateid_reaplist(struct list_head *reaplist)
>>  	}
>>  }
>>  
>> -static void release_lockowner(struct nfs4_lockowner *lo)
>> -{
>> -	struct nfs4_client *clp = lo->lo_owner.so_client;
>> -	struct nfs4_ol_stateid *stp;
>> -	struct list_head reaplist;
>> -
>> -	INIT_LIST_HEAD(&reaplist);
>> -
>> -	spin_lock(&clp->cl_lock);
>> -	unhash_lockowner_locked(lo);
>> -	while (!list_empty(&lo->lo_owner.so_stateids)) {
>> -		stp = list_first_entry(&lo->lo_owner.so_stateids,
>> -				struct nfs4_ol_stateid, st_perstateowner);
>> -		WARN_ON(!unhash_lock_stateid(stp));
>> -		put_ol_stateid_locked(stp, &reaplist);
>> -	}
>> -	spin_unlock(&clp->cl_lock);
>> -	free_ol_stateid_reaplist(&reaplist);
>> -	nfs4_put_stateowner(&lo->lo_owner);
>> -}
>> -
>>  static void release_open_stateid_locks(struct nfs4_ol_stateid *open_stp,
>>  				       struct list_head *reaplist)
>>  {
>> @@ -5945,6 +5924,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>>  	__be32 status;
>>  	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
>>  	struct nfs4_client *clp;
>> +	LIST_HEAD (reaplist);
>>  
>>  	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
>>  		clid->cl_boot, clid->cl_id);
>> @@ -5975,9 +5955,23 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>>  		nfs4_get_stateowner(sop);
>>  		break;
>>  	}
>> +	if (!lo) {
>> +		spin_unlock(&clp->cl_lock);
>> +		return status;
>> +	}
>> +
>> +	unhash_lockowner_locked(lo);
>> +	while (!list_empty(&lo->lo_owner.so_stateids)) {
>> +		stp = list_first_entry(&lo->lo_owner.so_stateids,
>> +				       struct nfs4_ol_stateid,
>> +				       st_perstateowner);
>> +		WARN_ON(!unhash_lock_stateid(stp));
>> +		put_ol_stateid_locked(stp, &reaplist);
>> +	}
>>  	spin_unlock(&clp->cl_lock);
>> -	if (lo)
>> -		release_lockowner(lo);
>> +	free_ol_stateid_reaplist(&reaplist);
>> +	nfs4_put_stateowner(&lo->lo_owner);
>> +
>>  	return status;
>>  }
>>  
>> 
> 
> 
> Your patch looks correct to me. Even if there is something else that
> prevents that race (and I don't see anything that does either), then
> still reduces the spinlock thrashing further. So...
> 
> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Thanks, I'll add your tag and put this through some testing.
Do you want to take this, or should it go through Bruce?

--
Chuck Lever




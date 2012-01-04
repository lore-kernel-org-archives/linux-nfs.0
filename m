Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:49122 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755462Ab2ADQIW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 11:08:22 -0500
Subject: Re: [PATCH 2/2] NFS: Cache state owners after files are closed
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1325692758.18462.10.camel@lade.trondhjem.org>
Date: Wed, 4 Jan 2012 11:08:17 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <CBB27FEB-BA9A-408E-85A7-A3F63F7B280B@oracle.com>
References: <20111206210723.5969.85159.stgit@degas.1015granger.net> <20111206211348.5969.61933.stgit@degas.1015granger.net> <1325692415.18462.6.camel@lade.trondhjem.org> <1325692758.18462.10.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 4, 2012, at 10:59 AM, Trond Myklebust wrote:

> On Wed, 2012-01-04 at 10:53 -0500, Trond Myklebust wrote: 
>> On Tue, 2011-12-06 at 16:13 -0500, Chuck Lever wrote: 
>>> Servers have a finite amount of memory to store NFSv4 open and lock
>>> owners.  Moreover, servers may have a difficult time determining when
>>> they can reap their state owner table, thanks to gray areas in the
>>> NFSv4 protocol specification.  Thus clients should be careful to reuse
>>> state owners when possible.
>>> 
>>> Currently Linux is not too careful.  When a user has closed all her
>>> files on one mount point, the state owner's reference count goes to
>>> zero, and it is released.  The next OPEN allocates a new one.  A
>>> workload that serially opens and closes files can run through a large
>>> number of open owners this way.
>>> 
>>> When a state owner's reference count goes to zero, slap it onto a free
>>> list for that nfs_server, with an expiry time.  Garbage collect before
>>> looking for a state owner.  This makes state owners for active users
>>> available for re-use.
>>> 
>>> Now that there can be unused state owners remaining at umount time,
>>> purge the state owner free list when a server is destroyed.  Also be
>>> sure not to reclaim unused state owners during state recovery.
>>> 
>>> This change has benefits for the client as well.  For some workloads,
>>> this approach drops the number of OPEN_CONFIRM calls from the same as
>>> the number of OPEN calls, down to just one.  This reduces wire traffic
>>> and thus open(2) latency.  Before this patch, untarring a kernel
>>> source tarball shows the OPEN_CONFIRM call counter steadily increasing
>>> through the test.  With the patch, the OPEN_CONFIRM count remains at 1
>>> throughout the entire untar.
>>> 
>>> As long as the expiry time is kept short, I don't think garbage
>>> collection should be terribly expensive, although it does bounce the
>>> clp->cl_lock around a bit.
>>> 
>>> [ At some point we should rationalize the use of the nfs_server
>>> ->destroy method. ]
>>> 
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>> <snip> 
>>> +
>>> +static void nfs4_gc_state_owners(struct nfs_server *server)
>>> +{
>>> +	struct nfs_client *clp = server->nfs_client;
>>> +	struct nfs4_state_owner *sp, *tmp;
>>> +	unsigned long now = jiffies;
>>> +	LIST_HEAD(doomed);
>>> +
>>> +	spin_lock(&clp->cl_lock);
>>> +	list_for_each_entry_safe(sp, tmp, &server->state_owners_lru, so_lru) {
>>> +		/* NB: LRU is sorted so that oldest is at the head */
>>> +		if (time_in_range(now, sp->so_expires,
>>> +				sp->so_expires + clp->cl_lease_time))
>>> +			break;
>>> +		list_move(&sp->so_lru, &doomed);
>>> +	}
>>> +	spin_unlock(&clp->cl_lock);
>> 
>> There is a race here: the state owner is still visible in the rb-tree,
>> and so a second thread that calls nfs4_get_state_owner() may still pick
>> up one of these open owners that are now on your 'doomed' list.
>> 
>> I think you rather need to do the equivalent of an
>> 'nfs4_drop_state_owner' in your loop above in order to be 100% safe.
>> 
>>> +	list_for_each_entry_safe(sp, tmp, &doomed, so_lru) {
>>> +		list_del_init(&sp->so_lru);
>>> +		nfs4_release_state_owner(sp);
>>> +	}
>>> +}
>>> +
>>> /**
>>>  * nfs4_get_state_owner - Look up a state owner given a credential
>>>  * @server: nfs_server to search
>>> @@ -483,11 +521,13 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
>>> 	struct nfs_client *clp = server->nfs_client;
>>> 	struct nfs4_state_owner *sp, *new;
>>> 
>>> +	nfs4_gc_state_owners(server);
>>> +
> 
> One more thing: doesn't it make more sense to do the garbage collection
> after you've looked up the state owner? Even if the open owner has been
> expired on the server, you will still gain by avoiding the extra
> allocation.

I think "GC first" is more fair.  If you really want to make sure an idle open owner is not re-used passed the sell-by, we have to do GC first.  Otherwise an open owner can languish for days if there's no other activity, and will get re-used on the next open.

It seems to me that on-the-wire behavior would be inconsistent if some open owners were re-used after a long idle, some were not, and the precise re-use behavior depended on workload.  "GC first" gives nicely predictable behavior.

> 
>>> 	spin_lock(&clp->cl_lock);
>>> 	sp = nfs4_find_state_owner_locked(server, cred);
>>> 	spin_unlock(&clp->cl_lock);
>>> 	if (sp != NULL)
>>> -		return sp;
>>> +		goto out;
>>> 	new = nfs4_alloc_state_owner();
>>> 	if (new == NULL)
>>> 		return NULL;
>>> @@ -502,26 +542,56 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
>>> 		rpc_destroy_wait_queue(&new->so_sequence.wait);
>>> 		kfree(new);
>>> 	}
>>> +out:
>>> +	list_del_init(&sp->so_lru);
>> 
>> Ehem... List corruption due to no spin lock. Doesn't it make more sense
>> to do the above inside nfs4_find/insert_state_owner_locked?
>> 
>>> 	return sp;
>>> }
>>> 
>> 
>> Otherwise it looks OK...
>> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





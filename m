Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3736 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041Ab1DNUUy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2011 16:20:54 -0400
Subject: Re: [PATCH] NFS: dont restart loop in nfs_delegation_reap_unclaimed
Content-Type: text/plain; charset=us-ascii
From: Dros Adamson <dros@netapp.com>
In-Reply-To: <1302809609.24028.66.camel@lade.trondhjem.org>
Date: Thu, 14 Apr 2011 16:20:37 -0400
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Message-Id: <B87FD6A0-EA41-47C9-985F-101035471BB1@netapp.com>
References: <1302807855-84959-1-git-send-email-dros@netapp.com> <F6E1551C-3A7B-4BD4-8C31-62996BEE2ACC@oracle.com> <1302809609.24028.66.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 14, 2011, at 3:33 PM, Trond Myklebust wrote:

> On Thu, 2011-04-14 at 15:10 -0400, Chuck Lever wrote:
>> On Apr 14, 2011, at 3:04 PM, Weston Andros Adamson wrote:
>> 
>>> The loop was being restarted after each delegation that has NFS_DELEGATION_NEED_RECLAIM
>>> set.  Instead, build a temporary list of delegations that need to be freed and free
>>> them after the for-each-delegation loop.
>>> 
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> fs/nfs/delegation.c |   16 +++++++++++-----
>>> 1 files changed, 11 insertions(+), 5 deletions(-)
>>> 
>>> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
>>> index bbbc6bf..c87fad8 100644
>>> --- a/fs/nfs/delegation.c
>>> +++ b/fs/nfs/delegation.c
>>> @@ -645,8 +645,8 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *clp)
>>> 	struct nfs_delegation *delegation;
>>> 	struct nfs_server *server;
>>> 	struct inode *inode;
>>> +	LIST_HEAD(tmplist);
>>> 
>>> -restart:
>>> 	rcu_read_lock();
>>> 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
>>> 		list_for_each_entry_rcu(delegation, &server->delegations,
>>> @@ -659,15 +659,21 @@ restart:
>>> 				continue;
>>> 			delegation = nfs_detach_delegation(NFS_I(inode),
>>> 								server);
>>> -			rcu_read_unlock();
>>> -
>>> +			/* super_list is unused now that deleg is detached */
>>> 			if (delegation != NULL)
>>> -				nfs_free_delegation(delegation);
>>> +				list_add(&delegation->super_list, &tmplist);
>>> +
>>> 			iput(inode);
>> 
>> /me idly wonders if that iput() is safe to do inside rcu_read_lock() / rcu_read_unlock().
> 
> It isn't....
> 
>>> -			goto restart;
>>> 		}
>>> 	}
>>> 	rcu_read_unlock();
>>> +
>>> +	while (!list_empty(&tmplist)) {
>>> +		delegation = list_first_entry(&tmplist, struct nfs_delegation,
>>> +					super_list);
>>> +		list_del(&delegation->super_list);
>>> +		nfs_free_delegation(delegation);
>>> +	}
>>> }
> 
> There is also the issue that the inode may have disappeared when we get
> to this stage; there is nothing pinning it in memory any more.
> 
> One suggestion would be to move the iput into the above loop.

Good points!  Sorry, I'm still trying to wrap my head around RCU...

> 
> The question is, though, whether or not we get much of a performance
> improvement.
> One advantage of the current scheme is that we're immediately freeing
> the delegation after detaching it. If you queue up the delegations for
> freeing, then a process that may need to free a delegation that is at
> the end of that list in order to make progress (because it wants to
> rename a file, or open it for writing) may have a longer wait during
> which the server will be replying NFS4ERR_DELAY.
> 
> Do we have any evidence for or against?

Well, the reason that I attempted to fix this is that it looks very wrong for this scenario:

  - there are many nfs_server structures with many delegations
  - servers at the end of the list have many delegations with NEED_RECLAIM set

In this case, we have terrible performance, iterating through the first N delegations (that don't need to be reclaimed) potentially many, many times.

In your example, the delegation that needs reclaiming is at the end of the list, so both methods need to traverse the whole server list and each of the delegation sub-lists.
If there is really only one (or a few) that need reclaiming, the difference between methods should be negligible.  If there are many that need reclaiming, the "dont restart the loop every time" method should be a clear winner.

The scenario where the "restart every time" loop is faster (for a waiting process) is when the only delegations that need reclaiming are at the beginning of the list-of-lists (the other method won't free until iterating through everything).

But my question is: once a delegation is detached, can't a waiting process progress?  as far as i can tell, nfs_free_delegation() is just a RCU safe wrapper for kfree().  nfs_detach_delegation() removes it from the list, and sets the nfs_inode's delegation pointer to NULL.  I'm new here, but as far as I can tell, at that point it should be out of the picture (outside of freeing it).

Maybe this work isn't needed.  It just looked wrong to me!

Thoughts?

-dros


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.efficios.com ([167.114.142.138]:52760 "EHLO
        mail.efficios.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934559AbeD0OO1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2018 10:14:27 -0400
Date: Fri, 27 Apr 2018 10:14:24 -0400 (EDT)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Josh Triplett <josh@joshtriplett.org>,
        rostedt <rostedt@goodmis.org>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Message-ID: <633967151.5813.1524838464457.JavaMail.zimbra@efficios.com>
In-Reply-To: <87h8nxkyjk.fsf@notabene.neil.brown.name>
References: <87h8nxkyjk.fsf@notabene.neil.brown.name>
Subject: Re: [PATCH] NFS: Avoid quadratic search when freeing delegations.
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- On Apr 27, 2018, at 1:29 AM, NeilBrown neilb@suse.com wrote:

> If an NFS client has 10,000 delegations which are between 90 and 180 seconds
> old,
> and 10,000 which are between 180 and 270 seconds old, with none of them still
> in use, it is likely that the old ones are at the end of the list.
> The first 10,000 will not be marked to be returned, the last 10,000 will.
> 
> To return these, the code starts at the front of the list and finds the
> first delegation needing to be returned (testing 10,000 on the way).
> Then it drops rcu_readlock(), returns the delegation and starts again,
> and does this 10,000 times.
> 
> As delegation return is async, it may never block, so these 10,000
> delegation will be returned without stopping for a breath.  The soft-lock
> detector will notice and complain.
> 
> This patch makes 3 changes.
> 
> 1/ cond_resched() is added so that the soft-lockup detector doesn't notice.
> 2/ A place-holder (an inode) is kept when locks are dropped, so that
>   the place can usually be found again after taking rcu_readlock().
>   This means we don't need to skip over 10,000 entries 10,000 times,
>   100 million pointless operations - which could eaisly be a larger
>   number.
> 3/ If nfs_sb_active() fails, break out of the loop - there is no point
>   in continuing.
> 
> The patch also add list_for_each_entry_from_rcu() to rculist.h in
> order to achieve 2/.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> Hi,
> I'm hoping one of the RCU reviewers will provide an Acked-by for the
> rculist.h change.
> 
> If you'ld like 3 patches instead of just one, please let me know.  But
> they all see to fit well together.

I think the RCU list API changes should sit in their own patch.

> 
> thanks,
> NeilBrown
> 
> 
> fs/nfs/delegation.c     | 57 ++++++++++++++++++++++++++++++++++++++++++++-----
> include/linux/rculist.h | 10 +++++++++
> 2 files changed, 62 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 1819d0d0ba4b..c3d9e21ab440 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -483,19 +483,56 @@ static bool nfs_delegation_need_return(struct
> nfs_delegation *delegation)
> int nfs_client_return_marked_delegations(struct nfs_client *clp)
> {
> 	struct nfs_delegation *delegation;
> +	struct nfs_delegation *prev;
> 	struct nfs_server *server;
> 	struct inode *inode;
> +	struct inode *place_holder = NULL;
> 	int err = 0;
> 
> restart:
> +	/*
> +	 * To avoid quadratic looping we hold an reference

an reference -> a reference

> +	 * to an inode place_holder.  Each time we restart, we
> +	 * list nfs_servers from the server of that inode, and
> +	 * delegation in the server from the delegations of that
> +	 * inode.
> +	 * prev is an RCU-protected pointer to a delegation which
> +	 * wasn't marked for return and might be a good choice for
> +	 * the next place_holder.
> +	 */
> 	rcu_read_lock();
> -	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
> -		list_for_each_entry_rcu(delegation, &server->delegations,
> -								super_list) {
> -			if (!nfs_delegation_need_return(delegation))
> +	prev = NULL;
> +	if (place_holder)
> +		server = NFS_SERVER(place_holder);
> +	else
> +		server = list_entry_rcu(clp->cl_superblocks.next,
> +					struct nfs_server, client_link);
> +	list_for_each_entry_from_rcu(server, &clp->cl_superblocks, client_link) {

Unless I'm missing something, you should define the delegation variable within
this scope.

> +		delegation = NULL;
> +		if (place_holder && server == NFS_SERVER(place_holder))
> +			delegation = rcu_dereference(NFS_I(place_holder)->delegation);
> +		if (!delegation)
> +			delegation = list_entry_rcu(server->delegations.next,
> +						    struct nfs_delegation, super_list);

AFAIU, what makes this work is that you expect grabbing the inode
reference will ensure the entry is not removed from the RCU list until
the iput().


> +		list_for_each_entry_from_rcu(delegation, &server->delegations, super_list) {
> +			struct inode *to_put = NULL;
> +
> +			if (!nfs_delegation_need_return(delegation)) {
> +				prev = delegation;
> 				continue;
> +			}
> 			if (!nfs_sb_active(server->super))
> -				continue;
> +				break;
> +
> +			if (prev) {
> +				struct inode *tmp;

missing whiteline, or the assignment can be done on the variable definition.

> +				tmp = nfs_delegation_grab_inode(prev);
> +				if (tmp) {
> +					to_put = place_holder;
> +					place_holder = tmp;
> +				}
> +			}
> +
> 			inode = nfs_delegation_grab_inode(delegation);
> 			if (inode == NULL) {
> 				rcu_read_unlock();
> @@ -505,16 +542,26 @@ int nfs_client_return_marked_delegations(struct nfs_client
> *clp)
> 			delegation = nfs_start_delegation_return_locked(NFS_I(inode));
> 			rcu_read_unlock();
> 
> +			if (to_put) {
> +				iput(to_put);
> +				to_put = NULL;

considering the scope of to_put, I think assigning it to NULL is redundant
with the variable definition.

> +			}
> +
> 			err = nfs_end_delegation_return(inode, delegation, 0);
> 			iput(inode);
> 			nfs_sb_deactive(server->super);
> +			cond_resched();
> 			if (!err)
> 				goto restart;
> 			set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
> +			if (place_holder)
> +				iput(place_holder);
> 			return err;
> 		}
> 	}
> 	rcu_read_unlock();
> +	if (place_holder)
> +		iput(place_holder);
> 	return 0;
> }
> 
> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
> index 127f534fec94..2d86f9869842 100644
> --- a/include/linux/rculist.h
> +++ b/include/linux/rculist.h
> @@ -403,6 +403,16 @@ static inline void list_splice_tail_init_rcu(struct
> list_head *list,
> 	     &pos->member != (head);	\
> 	     pos = list_entry_rcu(pos->member.next, typeof(*pos), member))
> 
> +/**
> + * list_for_each_entry_from_rcu - iterate over a list continuing from current
> point

There is some documentation missing about the requirements for continuing
a RCU list iteration.

The simple case is that both original iteration and continued iteration
need to be in the same RCU read-side critical section.

A more complex case like yours is along those lines:

rcu_read_lock()
list_iteration
   break;
grab inode ref (prohibit removal of node from list)
rcu_read_unlock()

rcu_read_lock()
put inode ref
continue list iteration
rcu_read_unlock()

I'm thinking these allowed patterns should be documented somehow,
else we'll see list iteration being continued across different
RCU read-side critical sections without any reference counting
(or locking) to ensure protection against removal.

Thanks,

Mathieu

> + * @pos:	the type * to use as a loop cursor.
> + * @head:	the head for your list.
> + * @member:	the name of the list_node within the struct.
> + */
> +#define list_for_each_entry_from_rcu(pos, head, member)			\
> +	for (; &(pos)->member != (head);					\
> +		pos = list_entry_rcu(pos->member.next, typeof(*(pos)), member))
> +
> /**
>  * hlist_del_rcu - deletes entry from hash list without re-initialization
>  * @n: the element to delete from the hash list.
> --
> 2.14.0.rc0.dirty

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

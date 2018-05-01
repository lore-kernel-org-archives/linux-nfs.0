Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52044 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753072AbeEAOMu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 May 2018 10:12:50 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w41E9FIU040714
        for <linux-nfs@vger.kernel.org>; Tue, 1 May 2018 10:12:50 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2hppyyxxf6-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Tue, 01 May 2018 10:12:49 -0400
Received: from localhost
        by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Tue, 1 May 2018 10:12:48 -0400
Date: Tue, 1 May 2018 07:14:04 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: NeilBrown <neilb@suse.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
        Josh Triplett <josh@joshtriplett.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, Lai Jiangshan <jiangshanlai@gmail.com>,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4 v2] rculist: add list_for_each_entry_from_rcu()
Reply-To: paulmck@linux.vnet.ibm.com
References: <152506256513.7246.13171564155614823841.stgit@noble>
 <152506269061.7246.13075216914692813995.stgit@noble>
 <20180430052032.GA16963@localhost>
 <20180430134308.GT26088@linux.vnet.ibm.com>
 <20180430111454.722c2aa8@gandalf.local.home>
 <20180430153505.GW26088@linux.vnet.ibm.com>
 <87y3h4gjdq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87y3h4gjdq.fsf@notabene.neil.brown.name>
Message-Id: <20180501141404.GD26088@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 01, 2018 at 01:11:29PM +1000, NeilBrown wrote:
> 
> list_for_each_entry_from_rcu() is an RCU version of
> list_for_each_entry_from().  It walks a linked list under rcu
> protection, from a given start point.
> 
> It is similar to list_for_each_entry_continue_rcu() but starts *at*
> the given position rather than *after* it.
> 
> Naturally, the start point must be known to be in the list.
> 
> Also update the documentation for list_for_each_entry_continue_rcu()
> to match the documentation for the new list_for_each_entry_from_rcu(),
> and add list_for_each_entry_from_rcu() and the already existing
> hlist_for_each_entry_from_rcu() to section 7 of whatisRCU.txt.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

I am guessing that it would be more convenient for you to carry this
with the patches using it, so:

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

If not, please let me know.

							Thanx, Paul

> ---
>  Documentation/RCU/whatisRCU.txt |  2 ++
>  include/linux/rculist.h         | 32 +++++++++++++++++++++++++++++++-
>  2 files changed, 33 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/RCU/whatisRCU.txt b/Documentation/RCU/whatisRCU.txt
> index a27fbfb0efb8..b7d38bd212d2 100644
> --- a/Documentation/RCU/whatisRCU.txt
> +++ b/Documentation/RCU/whatisRCU.txt
> @@ -814,11 +814,13 @@ RCU list traversal:
>  	list_next_rcu
>  	list_for_each_entry_rcu
>  	list_for_each_entry_continue_rcu
> +	list_for_each_entry_from_rcu
>  	hlist_first_rcu
>  	hlist_next_rcu
>  	hlist_pprev_rcu
>  	hlist_for_each_entry_rcu
>  	hlist_for_each_entry_rcu_bh
> +	hlist_for_each_entry_from_rcu
>  	hlist_for_each_entry_continue_rcu
>  	hlist_for_each_entry_continue_rcu_bh
>  	hlist_nulls_first_rcu
> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
> index 127f534fec94..4786c2235b98 100644
> --- a/include/linux/rculist.h
> +++ b/include/linux/rculist.h
> @@ -396,13 +396,43 @@ static inline void list_splice_tail_init_rcu(struct list_head *list,
>   * @member:	the name of the list_head within the struct.
>   *
>   * Continue to iterate over list of given type, continuing after
> - * the current position.
> + * the current position which must have been in the list when the RCU read
> + * lock was taken.
> + * This would typically require either that you obtained the node from a
> + * previous walk of the list in the same RCU read-side critical section, or
> + * that you held some sort of non-RCU reference (such as a reference count)
> + * to keep the node alive *and* in the list.
> + *
> + * This iterator is similar to list_for_each_entry_from_rcu() except
> + * this starts after the given position and that one starts at the given
> + * position.
>   */
>  #define list_for_each_entry_continue_rcu(pos, head, member) 		\
>  	for (pos = list_entry_rcu(pos->member.next, typeof(*pos), member); \
>  	     &pos->member != (head);	\
>  	     pos = list_entry_rcu(pos->member.next, typeof(*pos), member))
>  
> +/**
> + * list_for_each_entry_from_rcu - iterate over a list from current point
> + * @pos:	the type * to use as a loop cursor.
> + * @head:	the head for your list.
> + * @member:	the name of the list_node within the struct.
> + *
> + * Iterate over the tail of a list starting from a given position,
> + * which must have been in the list when the RCU read lock was taken.
> + * This would typically require either that you obtained the node from a
> + * previous walk of the list in the same RCU read-side critical section, or
> + * that you held some sort of non-RCU reference (such as a reference count)
> + * to keep the node alive *and* in the list.
> + *
> + * This iterator is similar to list_for_each_entry_continue_rcu() except
> + * this starts from the given position and that one starts from the position
> + * after the given position.
> + */
> +#define list_for_each_entry_from_rcu(pos, head, member)			\
> +	for (; &(pos)->member != (head);					\
> +		pos = list_entry_rcu(pos->member.next, typeof(*(pos)), member))
> +
>  /**
>   * hlist_del_rcu - deletes entry from hash list without re-initialization
>   * @n: the element to delete from the hash list.
> -- 
> 2.14.0.rc0.dirty
> 



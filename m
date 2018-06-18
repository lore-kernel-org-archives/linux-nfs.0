Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:60046 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933942AbeFRQ7Q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jun 2018 12:59:16 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5IGwrbh045928
        for <linux-nfs@vger.kernel.org>; Mon, 18 Jun 2018 12:59:16 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2jpfx8t431-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Mon, 18 Jun 2018 12:59:16 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Mon, 18 Jun 2018 12:59:14 -0400
Date: Mon, 18 Jun 2018 10:01:11 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: NeilBrown <neilb@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        trondmy@hammerspace.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rculist: improve documentation for
 list_for_each_entry_from_rcu()
Reply-To: paulmck@linux.vnet.ibm.com
References: <e5c90488937d14e9df81752a024be9d1e73ed398.camel@hammerspace.com>
 <CA+55aFxYMg+F9Jdi_25X-Qtt=7imqjQhLnjEyQXOQ6+eJvy83A@mail.gmail.com>
 <CA+55aFw+2+xCRAaMo8qgvZ7qNgRMo6D=WkwP7APQndG-y5b3dw@mail.gmail.com>
 <CA+55aFz3jmGST_cOB+qH6qZTFa5HJcw2JoeWxJEZdWgeO4=vNQ@mail.gmail.com>
 <20180613010427.GD3593@linux.vnet.ibm.com>
 <CA+55aFyWS-MC44k=LnGWr-Kq4_DRkJmub00Fj-tVrGxCL-PxGA@mail.gmail.com>
 <20180613013914.GE3593@linux.vnet.ibm.com>
 <87muvzihr8.fsf@notabene.neil.brown.name>
 <20180613100607.GH3593@linux.vnet.ibm.com>
 <874li0g1v3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <874li0g1v3.fsf@notabene.neil.brown.name>
Message-Id: <20180618170111.GB3593@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 18, 2018 at 02:22:40PM +1000, NeilBrown wrote:
> 
> Unfortunately the patch for adding list_for_each_entry_from_rcu()
> wasn't the final patch after all review.  It is functionally
> correct but the documentation was incomplete.
> 
> This patch adds this missing documentation which includes an update to
> the documentation for list_for_each_entry_continue_rcu() to match the
> documentation for the new list_for_each_entry_from_rcu(), and adds
> list_for_each_entry_from_rcu() and the already existing
> hlist_for_each_entry_from_rcu() to section 7 of whatisRCU.txt.
> 
> Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: NeilBrown <neilb@suse.com>

Once I rebase my commits to v4.18-rc1, I will apply this, thank you!

(If you were wanting something else to happen with this patch, please
let me know.)

							Thanx, Paul

> ---
>  Documentation/RCU/whatisRCU.txt |  2 ++
>  include/linux/rculist.h         | 19 ++++++++++++++++++-
>  2 files changed, 20 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/RCU/whatisRCU.txt b/Documentation/RCU/whatisRCU.txt
> index 65eb856526b7..d43524493fb3 100644
> --- a/Documentation/RCU/whatisRCU.txt
> +++ b/Documentation/RCU/whatisRCU.txt
> @@ -816,11 +816,13 @@ RCU list traversal:
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
> index 36df6ccbc874..4786c2235b98 100644
> --- a/include/linux/rculist.h
> +++ b/include/linux/rculist.h
> @@ -396,7 +396,16 @@ static inline void list_splice_tail_init_rcu(struct list_head *list,
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
> @@ -411,6 +420,14 @@ static inline void list_splice_tail_init_rcu(struct list_head *list,
>   *
>   * Iterate over the tail of a list starting from a given position,
>   * which must have been in the list when the RCU read lock was taken.
> + * This would typically require either that you obtained the node from a
> + * previous walk of the list in the same RCU read-side critical section, or
> + * that you held some sort of non-RCU reference (such as a reference count)
> + * to keep the node alive *and* in the list.
> + *
> + * This iterator is similar to list_for_each_entry_continue_rcu() except
> + * this starts from the given position and that one starts from the position
> + * after the given position.
>   */
>  #define list_for_each_entry_from_rcu(pos, head, member)			\
>  	for (; &(pos)->member != (head);					\
> -- 
> 2.14.0.rc0.dirty
> 



From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 1/2] rcu: add rcu_access_pointer and rcu_dereference_protect
Date: Wed, 07 Apr 2010 16:40:09 +0100
Message-ID: <25990.1270654809@redhat.com>
References: <1270652210.8141.9.camel@edumazet-laptop> <20100407135732.12414.16416.stgit@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>, paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932751Ab0DGPkT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Apr 2010 11:40:19 -0400
In-Reply-To: <1270652210.8141.9.camel@edumazet-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

> This is not the version Paul posted. 
> 
> Removing checks just to shutup warnings ?

No.  I don't see the point in the condition.

> All the point is to get lockdep assistance, and you throw it away.
> 
> We want to explicit the condition, so that RCU users can explicitly
> state what protects their data.

You've missed the point.

For rcu_access_pointer(), _nothing_ protects the data, not only that, we don't
care: we're only checking the pointer.

For rcu_dereference_protect[ed](), I don't see that the check helps.  You
don't need to be holding the RCU lock to call it, but you do need to hold all
the requisite locks required to exclude others modifying it.  That's a
precondition for calling this function, so is there any point in testing it
again?

For instance, consider the following pseudocode:

	do_something(struct foo *p)
	{
		struct bar *b;
		spin_lock(&foo->lock);
		b = rcu_dereference_protected(
			foo->bar, lockdep_is_held(&foo->lock));
		do_something_to_bar(b);
		spin_unlock(&foo->lock);
	}

is there any need for the condition?  Does lockdep_is_held() have any side
effects beyond those listed in the Documentation directory or on its attached
banner comments?


Furthermore, I think the condition in rcu_dereference_check() may well be
misused.  For instance, Paul suggested:

	cred = rcu_dereference_check(delegation->cred,
				     delegation->inode == NULL);

but if 'c' is supposed to be the locks that protect the data, is this a valid
check?

David

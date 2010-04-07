From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 1/2] rcu: add rcu_access_pointer and rcu_dereference_protect
Date: Wed, 07 Apr 2010 17:19:53 +0100
Message-ID: <26698.1270657193@redhat.com>
References: <1270656035.8141.23.camel@edumazet-laptop> <1270652210.8141.9.camel@edumazet-laptop> <20100407135732.12414.16416.stgit@warthog.procyon.org.uk> <25990.1270654809@redhat.com>
Cc: dhowells@redhat.com, paulmck@linux.vnet.ibm.com,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1192 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932539Ab0DGQT6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Apr 2010 12:19:58 -0400
In-Reply-To: <1270656035.8141.23.camel@edumazet-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > You've missed the point.
> 
> You already claimed I dont understand RCU. I find this claim funny.
> 
> > For rcu_access_pointer(), _nothing_ protects the data, not only that, we
> > don't care: we're only checking the pointer.
> 
> How can you state this ?
> 
> Thats pretty simple, "always true" is a fine condition.
> 
> What's the problem with this ?

If the condition for rcu_access_pointer() is always "always true", then it's
redundant, right?  rcu_access_pointer() is for checking the pointer only, not
checking the payload that pointer might point to.  So, what condition are you
supposed to be checking?
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > but if 'c' is supposed to be the locks that protect the data, is this a
> > valid check?
> 
> 'c' is not a lock. Its a condition.

Sorry, I meant the state of the relevant locking context.

To take your example:

> filter = rcu_dereference_check(sk->sk_filter,
> 			       atomic_read(&sk->sk_wmem_alloc) == 0);

what is the value of sk->sk_wmem_alloc to the lock context of sk->sk_filter?
Why would lockdep be interested in sk_wmem_alloc?

Surely, the assertion that the value of sk->sk_filter is related to
sk_wmem_alloc being 0 is independent of the need to dereference sk_filter for
RCU purposes.  So why are these being combined?

Why not:

	ASSERT(atomic_read(&sk->sk_wmem_alloc) == 0);
	filter = rcu_dereference(sk->sk_filter);

This is much clearer, and you're not combining an unrelated assertion with the
RCU dereference.

David

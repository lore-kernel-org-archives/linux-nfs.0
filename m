Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42517 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755458Ab2IFOUi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 10:20:38 -0400
Message-ID: <5048B0F5.9040000@redhat.com>
Date: Thu, 06 Sep 2012 15:19:33 +0100
From: Pedro Alves <palves@redhat.com>
MIME-Version: 1.0
To: Sasha Levin <levinsasha928@gmail.com>
CC: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>,
        torvalds@linux-foundation.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu,
        ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com,
        netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com,
        axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de,
        ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com,
        bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com,
        venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com,
        edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
References: <20120824230740.GN21325@google.com> <20120825042419.GA27240@Krystal> <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal> <503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal> <20120828230050.GA3337@Krystal> <1346772948.27919.9.camel@gandalf.local.home> <50462C99.5000007@redhat.com> <50462EE8.1090903@redhat.com> <20120904170138.GB31934@Krystal> <5048AAF6.5090101@gmail.com>
In-Reply-To: <5048AAF6.5090101@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/06/2012 02:53 PM, Sasha Levin wrote:

> So I think that for the hash iterator it might actually be simpler.
> 
> My solution to making 'break' work in the iterator is:
> 
> 	for (bkt = 0, node = NULL; bkt < HASH_SIZE(name) && node == NULL; bkt++)
> 		hlist_for_each_entry(obj, node, &name[bkt], member)
> 
> We initialize our node loop cursor with NULL in the external loop, and the
> external loop will have a new condition to loop while that cursor is NULL.
> 
> My logic is that we can only 'break' when we are iterating over an object in the
> internal loop. If we're iterating over an object in that loop then 'node != NULL'.
> 
> This way, if we broke from within the internal loop, the external loop will see
> node as not NULL, and so it will stop looping itself. On the other hand, if the
> internal loop has actually ended, then node will be NULL, and the outer loop
> will keep running.
> 
> Is there anything I've missed?

Looks right to me, from a cursory look at hlist_for_each_entry.  That's exactly
what I meant with this most often being trivial when the inner loop's iterator
is a pointer that goes NULL at the end.

-- 
Pedro Alves


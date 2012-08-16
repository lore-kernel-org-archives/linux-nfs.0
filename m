Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.openrapids.net ([64.15.138.104]:57872 "EHLO
	blackscsi.openrapids.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753007Ab2HPO2Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2012 10:28:25 -0400
Date: Thu, 16 Aug 2012 10:28:22 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: David Laight <David.Laight@ACULAB.COM>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Sasha Levin <levinsasha928@gmail.com>, torvalds@linux-foundation.org,
        tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
        rostedt@goodmis.org, mingo@elte.hu, aarcange@redhat.com,
        ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org,
        eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
        teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
        fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
        ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
        linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH 02/16] user_ns: use new hashtable implementation
Message-ID: <20120816142821.GC29703@Krystal>
References: <502AFCD5.6070104@gmail.com> <87obmchmpu.fsf@xmission.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6FB5@saturn3.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FB5@saturn3.aculab.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* David Laight (David.Laight@ACULAB.COM) wrote:
> > Yes hash_32 seems reasonable for the uid hash.   With those long hash
> > chains I wouldn't like to be on a machine with 10,000 processes with
> > each with a different uid, and a processes calling setuid in the fast
> > path.
> > 
> > The uid hash that we are playing with is one that I sort of wish that
> > the hash table could grow in size, so that we could scale up better.
> 
> Since uids are likely to be allocated in dense blocks, maybe an
> unhashed multi-level lookup scheme might be appropriate.
> 
> Index an array with the low 8 (say) bits of the uid.
> Each item can be either:  
>   1) NULL => free entry.
>   2) a pointer to a uid structure (check uid value).
>   3) a pointer to an array to index with the next 8 bits.
> (2) and (3) can be differentiated by the low address bit.

I'm currently experimenting with "Judy arrays", which would likely be a
good fit for this kind of use-case.

It's basically a 256-ary trie, with fixed depth that depends on the key
size, that uses various encoding (compaction) schemes to compress
internal nodes depending on their density. The original implementation
made by HP has been criticised as somewhat too complex (20k lines of
code), but I'm currently working (in my spare time) on a more elegant
solution, that supports RCU lookups and distributed locking, and uses
much simpler node compaction schemes, and focus on having good cache
locality (and minimal number of cache line hits) for lookups.

I'll be presenting my ongoing work at Plumbers, if you are interested.

Best regards,

Mathieu

> I think that is updateable with cmpxchg.
> 
> Clearly this is a bad algorithm if uids are all multiples of 2^24
> but that is true or any hash function.
> 
> 	David
> 
> 
> 

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.openrapids.net ([64.15.138.104]:58959 "EHLO
	blackscsi.openrapids.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754860Ab2J2SfN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 14:35:13 -0400
Date: Mon, 29 Oct 2012 14:35:10 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: Tejun Heo <tj@kernel.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, torvalds@linux-foundation.org,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
        rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com,
        aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org,
        josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk,
        agk@redhat.com, dm-devel@redhat.com, neilb@suse.de,
        ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com,
        bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com,
        venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com,
        edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH v7 15/16] openvswitch: use new hashtable implementation
Message-ID: <20121029183510.GA21114@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-15-git-send-email-levinsasha928@gmail.com> <20121029132931.GC16391@Krystal> <CA+1xoqfRGhPaBEVh228O5_295bWh8FmcyLSOwq8VE5Dm7i3JHg@mail.gmail.com> <20121029155957.GB18834@Krystal> <CA+1xoqcr5xmOkDfqL3P84CNdotOALOhiLRkJjsPCZzijSQUF6w@mail.gmail.com> <20121029181648.GB20796@Krystal> <20121029182209.GB4066@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121029182209.GB4066@htj.dyndns.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Tejun Heo (tj@kernel.org) wrote:
> Hello,
> 
> On Mon, Oct 29, 2012 at 02:16:48PM -0400, Mathieu Desnoyers wrote:
> > This is just one example in an attempt to show why different hash table
> > users may have different constraints: for a hash table entirely
> > populated by keys generated internally by the kernel, a random seed
> > might not be required, but for cases where values are fed by user-space
> > and from the NIC, I would argue that flexibility to implement a
> > randomizable hash function beats implementation simplicity any time.
> > 
> > And you could keep the basic use-case simple by providing hints to the
> > hash_32()/hash_64()/hash_ulong() helpers in comments.
> 
> If all you need is throwing in a salt value to avoid attacks, can't
> you just do that from caller side?  Scrambling the key before feeding
> it into hash_*() should work, no?

Yes, I think salting the "key" parameter would work.

Thanks,

Mathieu

> 
> Thanks.
> 
> -- 
> tejun

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

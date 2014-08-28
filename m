Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51512 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965124AbaH1JZR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Aug 2014 05:25:17 -0400
Date: Thu, 28 Aug 2014 10:25:10 +0100
From: Mel Gorman <mgorman@suse.com>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Johannes Weiner <hannes@cmpxchg.org>, NeilBrown <neilb@suse.de>,
        Michal Hocko <mhocko@suse.cz>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
Message-ID: <20140828092510.GK12374@novell.com>
References: <20140826105304.GT17696@novell.com>
 <CAHQdGtRMFuH9MsJBj5YsOrJW+qFLFp_-X=b_gZPVmgVQ22swqQ@mail.gmail.com>
 <20140826132624.GU17696@novell.com>
 <20140826231938.GA13889@cmpxchg.org>
 <CAHQdGtRPsVFVfph5OcsZk_+WYPPJ-MpE2myZfXAb3jq6fuM4zw@mail.gmail.com>
 <CAHQdGtQPMJNzSM5Wt4RnNqEawBLqmYHycXTmBHhmAt26dz5wCw@mail.gmail.com>
 <20140827153644.GF12374@novell.com>
 <CAHQdGtQGqw9H=io0bYGKCCS1DxHZZymGjTCoiRymKnX2i88w_w@mail.gmail.com>
 <20140828083053.GJ12374@novell.com>
 <53FEED2A.2050209@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
In-Reply-To: <53FEED2A.2050209@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 28, 2014 at 04:49:46PM +0800, Junxiao Bi wrote:
> >>>>>> <SNIP>
> >>>>>> Can't you use mempools like the other IO paths?
> >>>>>
> >>>>> There is no way to pass any allocation flags at all to an operation
> >>>>> such as __sock_create() (which may be needed if the server
> >>>>> disconnects). So in general, the answer is no.
> >>>>>
> >>>>
> >>>> Actually, one question that should probably be raised before anything
> >>>> else: is it at all possible for a workqueue like rpciod to have a
> >>>> non-trivial setting for ->target_mem_cgroup? If not, then the whole
> >>>> question is moot.
> >>>>
> >>>
> >>> AFAIK, today it's not possible to add kernel threads (which rpciod is one)
> >>> to a memcg so the issue is entirely theoritical at the moment.  Even if
> >>> this was to change, it's not clear to me what adding kernel threads to a
> >>> memcg would mean as kernel threads have no RSS. Even if kernel resources
> >>> were accounted for, I cannot see why a kernel thread would join a memcg.
> >>>
> >>> I expec that it's currently impossible for rpciod to have a non-trivial
> >>> target_mem_cgroup. The memcg folk will correct me if I'm wrong or if there
> >>> are plans to change that for some reason.
> >>>
> >>
> >> Thanks! Then I'll assume that the problem is nonexistent in upstream
> >> for now, and drop the idea of using PF_MEMALLOC_NOIO. Perhaps we can
> >> then encourage Junxiao to look into backporting some of the VM changes
> >> in order to fix his Oracle legacy kernel issues?
> >>
> > 
> > Sounds like a plan to me. The other alternative would be backporting the
> > handling of wait_on_page_writeback and writeback handling from reclaim but
> > that would be much harder considering the rate of change in vmscan.c and
> > the problems that were experienced with high CPU usage from kswapd during
> > that transition.
>
> Backport the vm changes may cause a lot of risk due to lots of changes,
> i am thinking to check PF_FSTRANS flag in shrink_page_list() to bypass
> the fs ops in our old kernel. Can this cause other issue?
> 

I'm afraid that depends on exactly how the kernel you are
backporting to interprets PF_FSTRANS. Your original bug was related
to wait_on_page_writeback so you'll need to check if PF_FSTRANS is
interpreted as !may_enter_fs in reclaim context in your kernel to avoid
the wait_on_page_writeback.

-- 
Mel Gorman
SUSE Labs

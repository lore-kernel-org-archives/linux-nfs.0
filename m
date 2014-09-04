Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:51868 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbaIDNyc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 09:54:32 -0400
Date: Thu, 4 Sep 2014 15:54:27 +0200
From: Michal Hocko <mhocko@suse.cz>
To: Mel Gorman <mgorman@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Johannes Weiner <hannes@cmpxchg.org>, NeilBrown <neilb@suse.de>,
        Junxiao Bi <junxiao.bi@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
Message-ID: <20140904135427.GA14548@dhcp22.suse.cz>
References: <53F6F772.6020708@oracle.com>
 <1408747772-37938-1-git-send-email-trond.myklebust@primarydata.com>
 <20140825164852.50723141@notabene.brown>
 <20140826105304.GT17696@novell.com>
 <CAHQdGtRMFuH9MsJBj5YsOrJW+qFLFp_-X=b_gZPVmgVQ22swqQ@mail.gmail.com>
 <20140826132624.GU17696@novell.com>
 <20140826231938.GA13889@cmpxchg.org>
 <CAHQdGtRPsVFVfph5OcsZk_+WYPPJ-MpE2myZfXAb3jq6fuM4zw@mail.gmail.com>
 <CAHQdGtQPMJNzSM5Wt4RnNqEawBLqmYHycXTmBHhmAt26dz5wCw@mail.gmail.com>
 <20140827153644.GF12374@novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140827153644.GF12374@novell.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[Sorry for jumping in so late - I've been busy last days]

On Wed 27-08-14 16:36:44, Mel Gorman wrote:
> On Tue, Aug 26, 2014 at 08:00:20PM -0400, Trond Myklebust wrote:
> > On Tue, Aug 26, 2014 at 7:51 PM, Trond Myklebust
> > <trond.myklebust@primarydata.com> wrote:
> > > On Tue, Aug 26, 2014 at 7:19 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
[...]
> > >> wait_on_page_writeback() is a hammer, and we need to be better about
> > >> this once we have per-memcg dirty writeback and throttling, but I
> > >> think that really misses the point.  Even if memcg writeback waiting
> > >> were smarter, any length of time spent waiting for yourself to make
> > >> progress is absurd.  We just shouldn't be solving deadlock scenarios
> > >> through arbitrary timeouts on one side.  If you can't wait for IO to
> > >> finish, you shouldn't be passing __GFP_IO.

Exactly!

> > >> Can't you use mempools like the other IO paths?
> > >
> > > There is no way to pass any allocation flags at all to an operation
> > > such as __sock_create() (which may be needed if the server
> > > disconnects). So in general, the answer is no.
> > >
> > 
> > Actually, one question that should probably be raised before anything
> > else: is it at all possible for a workqueue like rpciod to have a
> > non-trivial setting for ->target_mem_cgroup? If not, then the whole
> > question is moot.
> 
> AFAIK, today it's not possible to add kernel threads (which rpciod is one)
> to a memcg so the issue is entirely theoritical at the moment.  Even if
> this was to change, it's not clear to me what adding kernel threads to a
> memcg would mean as kernel threads have no RSS. Even if kernel resources
> were accounted for, I cannot see why a kernel thread would join a memcg.

It doesn't make _any_ sense to assign kernel threads to memcg as they do
not have mm_struct associated with them and mm_struct is the central
association point to memcg. I do not see any reason this to change in
the future.

> I expec that it's currently impossible for rpciod to have a non-trivial
> target_mem_cgroup. The memcg folk will correct me if I'm wrong or if there
> are plans to change that for some reason.

The only possible case would be if the rpciod would use_mm of current
for some reason.

-- 
Michal Hocko
SUSE Labs

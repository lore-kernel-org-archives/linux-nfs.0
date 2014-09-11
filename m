Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f179.google.com ([209.85.212.179]:43847 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbaIKIuv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 04:50:51 -0400
Date: Thu, 11 Sep 2014 10:50:47 +0200
From: Michal Hocko <mhocko@suse.cz>
To: NeilBrown <neilb@suse.de>
Cc: Mel Gorman <mgorman@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Junxiao Bi <junxiao.bi@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
Message-ID: <20140911085046.GC22042@dhcp22.suse.cz>
References: <CAHQdGtRMFuH9MsJBj5YsOrJW+qFLFp_-X=b_gZPVmgVQ22swqQ@mail.gmail.com>
 <20140826132624.GU17696@novell.com>
 <20140826231938.GA13889@cmpxchg.org>
 <CAHQdGtRPsVFVfph5OcsZk_+WYPPJ-MpE2myZfXAb3jq6fuM4zw@mail.gmail.com>
 <CAHQdGtQPMJNzSM5Wt4RnNqEawBLqmYHycXTmBHhmAt26dz5wCw@mail.gmail.com>
 <20140827153644.GF12374@novell.com>
 <20140904135427.GA14548@dhcp22.suse.cz>
 <20140909123346.434f0443@notabene.brown>
 <20140910134842.GG25219@dhcp22.suse.cz>
 <20140911095743.1ed87519@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140911095743.1ed87519@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu 11-09-14 09:57:43, Neil Brown wrote:
> On Wed, 10 Sep 2014 15:48:43 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Tue 09-09-14 12:33:46, Neil Brown wrote:
> > > On Thu, 4 Sep 2014 15:54:27 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> > > 
> > > > [Sorry for jumping in so late - I've been busy last days]
> > > > 
> > > > On Wed 27-08-14 16:36:44, Mel Gorman wrote:
> > > > > On Tue, Aug 26, 2014 at 08:00:20PM -0400, Trond Myklebust wrote:
> > > > > > On Tue, Aug 26, 2014 at 7:51 PM, Trond Myklebust
> > > > > > <trond.myklebust@primarydata.com> wrote:
> > > > > > > On Tue, Aug 26, 2014 at 7:19 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > > [...]
> > > > > > >> wait_on_page_writeback() is a hammer, and we need to be better about
> > > > > > >> this once we have per-memcg dirty writeback and throttling, but I
> > > > > > >> think that really misses the point.  Even if memcg writeback waiting
> > > > > > >> were smarter, any length of time spent waiting for yourself to make
> > > > > > >> progress is absurd.  We just shouldn't be solving deadlock scenarios
> > > > > > >> through arbitrary timeouts on one side.  If you can't wait for IO to
> > > > > > >> finish, you shouldn't be passing __GFP_IO.
> > > > 
> > > > Exactly!
> > > 
> > > This is overly simplistic.
> > > The code that cannot wait may be further up the call chain and not in a
> > > position to avoid passing __GFP_IO.
> > > In many case it isn't that "you can't wait for IO" in general, but that you
> > > cannot wait for one specific IO request.
> > 
> > Could you be more specific, please? Why would a particular IO make any
> > difference to general IO from the same path? My understanding was that
> > once the page is marked PG_writeback then it is about to be written to
> > its destination and if there is any need for memory allocation it should
> > better not allow IO from reclaim.
> 
> The more complex the filesystem, the harder it is to "not allow IO from
> reclaim".
> For NFS (which started this thread) there might be a need to open a new
> connection - so allocating in the networking code would all need to be
> careful.

memalloc_noio_{save,restor} might help in that regards.

> And it isn't impossible that a 'gss' credential needs to be re-negotiated,
> and that might even need user-space interaction (not sure of details).

OK, so if I understand you correctly all those allocations tmight happen
_after_ the page has been marked PG_writeback. This would be bad indeed
if such a path could appear in the memcg limit reclaim. The outcome of
the previous discussion was that this doesn't happen in practice for
nfs code, though, because the real flushing doesn't happen from a user
context. The issue was reported for an old kernel where the flushing
happened from the user context. It would be a huge problem to have a
flusher within a restricted environment not only because of this path.

> What you say certainly used to be the case, and very often still is.  But it
> doesn't really scale with complexity of filesystems.
> 
> I don't think there is (yet) any need to optimised for allocations that don't
> disallow IO happening in the writeout path.  But I do think waiting
> indefinitely for a particular IO is unjustifiable.

Well, as Johannes already pointed out. The right way to fix memcg
reclaim is to implement proper memcg aware dirty pages throttling and
flushing. This is a song of distant future I am afraid. Until then we
have to live with workarounds. I would be happy to make this one more
robust but timeout based solutions just sound too fragile and triggering
OOM is a big risk.

Maybe we can disbale waiting if current->flags & PF_LESS_THROTTLE. I
would be even tempted to WARN_ON(current->flags & PF_LESS_THROTTLE) in
that path to catch a potential misconfiguration when the flusher is a
part of restricted environment. The only real user of the flag is nfsd
though and it runs from a kernel thread so this wouldn't help much to
catch potentialy buggy code. So I am not really sure how much of an
improvement this would be.

-- 
Michal Hocko
SUSE Labs

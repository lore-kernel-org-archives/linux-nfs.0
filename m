Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f181.google.com ([209.85.212.181]:62917 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbaIJNsq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 09:48:46 -0400
Date: Wed, 10 Sep 2014 15:48:43 +0200
From: Michal Hocko <mhocko@suse.cz>
To: NeilBrown <neilb@suse.de>
Cc: Mel Gorman <mgorman@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Junxiao Bi <junxiao.bi@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
Message-ID: <20140910134842.GG25219@dhcp22.suse.cz>
References: <20140825164852.50723141@notabene.brown>
 <20140826105304.GT17696@novell.com>
 <CAHQdGtRMFuH9MsJBj5YsOrJW+qFLFp_-X=b_gZPVmgVQ22swqQ@mail.gmail.com>
 <20140826132624.GU17696@novell.com>
 <20140826231938.GA13889@cmpxchg.org>
 <CAHQdGtRPsVFVfph5OcsZk_+WYPPJ-MpE2myZfXAb3jq6fuM4zw@mail.gmail.com>
 <CAHQdGtQPMJNzSM5Wt4RnNqEawBLqmYHycXTmBHhmAt26dz5wCw@mail.gmail.com>
 <20140827153644.GF12374@novell.com>
 <20140904135427.GA14548@dhcp22.suse.cz>
 <20140909123346.434f0443@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140909123346.434f0443@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue 09-09-14 12:33:46, Neil Brown wrote:
> On Thu, 4 Sep 2014 15:54:27 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > [Sorry for jumping in so late - I've been busy last days]
> > 
> > On Wed 27-08-14 16:36:44, Mel Gorman wrote:
> > > On Tue, Aug 26, 2014 at 08:00:20PM -0400, Trond Myklebust wrote:
> > > > On Tue, Aug 26, 2014 at 7:51 PM, Trond Myklebust
> > > > <trond.myklebust@primarydata.com> wrote:
> > > > > On Tue, Aug 26, 2014 at 7:19 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > [...]
> > > > >> wait_on_page_writeback() is a hammer, and we need to be better about
> > > > >> this once we have per-memcg dirty writeback and throttling, but I
> > > > >> think that really misses the point.  Even if memcg writeback waiting
> > > > >> were smarter, any length of time spent waiting for yourself to make
> > > > >> progress is absurd.  We just shouldn't be solving deadlock scenarios
> > > > >> through arbitrary timeouts on one side.  If you can't wait for IO to
> > > > >> finish, you shouldn't be passing __GFP_IO.
> > 
> > Exactly!
> 
> This is overly simplistic.
> The code that cannot wait may be further up the call chain and not in a
> position to avoid passing __GFP_IO.
> In many case it isn't that "you can't wait for IO" in general, but that you
> cannot wait for one specific IO request.

Could you be more specific, please? Why would a particular IO make any
difference to general IO from the same path? My understanding was that
once the page is marked PG_writeback then it is about to be written to
its destination and if there is any need for memory allocation it should
better not allow IO from reclaim.

> wait_on_page_writeback() waits for a specific IO and so is dangerous.
> congestion_wait() or similar waits for IO in general and so is much safer.

congestion_wait was actually not sufficient to prevent from OOM with
heavy writer in a small memcg. We simply do not know how long will the
IO last so any "wait for a random timeout" will end up causing some
troubles.
-- 
Michal Hocko
SUSE Labs

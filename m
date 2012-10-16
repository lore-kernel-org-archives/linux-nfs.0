Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60928 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193Ab2JPKd4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Oct 2012 06:33:56 -0400
Date: Tue, 16 Oct 2012 06:33:48 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chen Gang <gang.chen@asianux.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [Bug fix] nfs-client: fix nfs_inode_attrs_need_update for async
 read_done comes during truncating to smaller size
Message-ID: <20121016063348.7b225bfb@tlielax.poochiereds.net>
In-Reply-To: <507CDEF2.2060809@asianux.com>
References: <507B70F1.7040903@asianux.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA909236BB5@SACEXCMBX04-PRD.hq.netapp.com>
	<507B968A.9090104@asianux.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90923F1C4@SACEXCMBX04-PRD.hq.netapp.com>
	<507CBA3F.6000204@asianux.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA909253103@SACEXCMBX04-PRD.hq.netapp.com>
	<507CDEF2.2060809@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 16 Oct 2012 12:13:38 +0800
Chen Gang <gang.chen@asianux.com> wrote:

> 于 2012年10月16日 10:51, Myklebust, Trond 写道:
> 
> >>
> >> 1) is it means: nfs_inode_attrs_need_update need not consider async
> >> read_done situation ?
> > 
> > I don't understand what you mean. This is mainly about the asynchronous
> > write situation...
> 
> for async read done, it will call nfs_readpage_result -> nfs_read_done
> -> nfs_refresh_inode -> nfs_refresh_inode_locked ->
> nfs_inode_attrs_need_update -> nfs_size_need_update.
> 
> we need consider the situation that "async read_done also call
> nfs_size_need_update with an old useless larger file size".
> 
> you means, it need not consider async read (only consider async write is
> enough), is it correct ?
> 
> > 
> > No... If I did, I would have changed this 15 years ago when I was
> > writing that code. Nothing here is new... 2.6.27-rc9 has the exact same
> > heuristics.
> 
> 1) I have read the relative source code of 2.6.27-rc9, it is truly no
> nfs_size_need_update function.
> 
> 2) I have test the 2.6.27-rc9, it truly pass the LTP test of udp+nfsv2.
> 
> 3) I got the 2.6.27-rc9 source code by this way (please check)
>    A) get source code from (git clone)
> git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
>    B) git archive v2.6.27-rc9 | tar -xf - -C ../2.6.27-rc9/
> 
> 
> > It boils down to the rule that if you want to ensure that data is not
> > _lost_, then you have to ensure that the cached file size is not less
> > than the true file size.
> > 
> 
> 1) you means: in some condition, the cached file size can be bigger than
> the true file size ?  can you give some example (which no negative
> effect for correctness) ?
> 
> 2) What I feel:
>    A) I am not quite familiar with nfs (so truly need your information);
>    B) I think it is truly a bug, but maybe nfs_size_need_update is not
> the root cause (so need nfs maintainers' audit)
>    C) if nfs_size_need_update is truly not the root cause, I shall
> continue analysing it, after get enough information from nfs maintainers.
> 
> 
> >>   B) the test tools which I use is from the LTP (Linux Test Project),
> >> they use both udp and tcp to test both the nfsv2 and nfsv3.
> > 
> > So what combinations are failing?
> 
> for udp + nfsv2 failing (I am not test udp + nfsv3)
> 


The problem is a little more fundamental than that. The attr cache
handling logic is some of the trickiest code to deal with in the NFS
client.

In any situation where we get back attributes, we have to decide
whether they are valid or stale. It's always possible for replies or
their handling to be reordered such that an older set of attributes
is processed after a newer set.

Unfortunately, the v2/v3 protocols do not have great support for
helping the client detect this situation, so we do the best we can with
what we do have. Unfortunately when things are changing very quickly we
can still get it wrong, especially with v2/3. [1]

In any case, the logic to determine this is in
nfs_inode_attrs_need_update(). Looking at the size is sort of the "last
resort" after we look at the timestamps and gencount.

The problem with doing what you suggest is that if we get it wrong, the
consequences are worse than the file appearing to be bigger than it is.
It means that written data may be silently lost.

======

[1]: v4 has a change attribute so it's slightly simpler there when the
server supports it. Unrelated Q for Trond: should we be checking the v4
change_attr in nfs_inode_attrs_need_update too? 

-- 
Jeff Layton <jlayton@redhat.com>

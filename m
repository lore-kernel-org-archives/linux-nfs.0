Return-Path: linux-nfs-owner@vger.kernel.org
Received: from intranet.asianux.com ([58.214.24.6]:19726 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265Ab2JPEMg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Oct 2012 00:12:36 -0400
Message-ID: <507CDEF2.2060809@asianux.com>
Date: Tue, 16 Oct 2012 12:13:38 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [Bug fix] nfs-client: fix nfs_inode_attrs_need_update for async
 read_done comes during truncating to smaller size
References: <507B70F1.7040903@asianux.com>   <4FA345DA4F4AE44899BD2B03EEEC2FA909236BB5@SACEXCMBX04-PRD.hq.netapp.com>   <507B968A.9090104@asianux.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA90923F1C4@SACEXCMBX04-PRD.hq.netapp.com>  <507CBA3F.6000204@asianux.com> <4FA345DA4F4AE44899BD2B03EEEC2FA909253103@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA909253103@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

于 2012年10月16日 10:51, Myklebust, Trond 写道:

>>
>> 1) is it means: nfs_inode_attrs_need_update need not consider async
>> read_done situation ?
> 
> I don't understand what you mean. This is mainly about the asynchronous
> write situation...

for async read done, it will call nfs_readpage_result -> nfs_read_done
-> nfs_refresh_inode -> nfs_refresh_inode_locked ->
nfs_inode_attrs_need_update -> nfs_size_need_update.

we need consider the situation that "async read_done also call
nfs_size_need_update with an old useless larger file size".

you means, it need not consider async read (only consider async write is
enough), is it correct ?

> 
> No... If I did, I would have changed this 15 years ago when I was
> writing that code. Nothing here is new... 2.6.27-rc9 has the exact same
> heuristics.

1) I have read the relative source code of 2.6.27-rc9, it is truly no
nfs_size_need_update function.

2) I have test the 2.6.27-rc9, it truly pass the LTP test of udp+nfsv2.

3) I got the 2.6.27-rc9 source code by this way (please check)
   A) get source code from (git clone)
git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
   B) git archive v2.6.27-rc9 | tar -xf - -C ../2.6.27-rc9/


> It boils down to the rule that if you want to ensure that data is not
> _lost_, then you have to ensure that the cached file size is not less
> than the true file size.
> 

1) you means: in some condition, the cached file size can be bigger than
the true file size ?  can you give some example (which no negative
effect for correctness) ?

2) What I feel:
   A) I am not quite familiar with nfs (so truly need your information);
   B) I think it is truly a bug, but maybe nfs_size_need_update is not
the root cause (so need nfs maintainers' audit)
   C) if nfs_size_need_update is truly not the root cause, I shall
continue analysing it, after get enough information from nfs maintainers.


>>   B) the test tools which I use is from the LTP (Linux Test Project),
>> they use both udp and tcp to test both the nfsv2 and nfsv3.
> 
> So what combinations are failing?

for udp + nfsv2 failing (I am not test udp + nfsv3)

> 
>>   C) truly LTP has its limitations: "for stress test, LTP let nfs client
>> and server under the same machine, which will cause kernel stable
>> issue", but for net test, LTP use different machine (I got our issue
>> from LTP net test).
> 
> Running the client and server on the same machine is likely to deadlock
> due to memory pressure issues. The client needs to be able to _increase_
> memory pressure on the server in order to reduce its own pressure. That
> doesn't work well when client == server.
> 

truly got confirmation from Jeff Layton, 1-2 months ago;
also thank you for giving confirmation too.

-- 
Chen Gang

Asianux Corporation

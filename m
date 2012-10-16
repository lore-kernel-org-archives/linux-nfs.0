Return-Path: linux-nfs-owner@vger.kernel.org
Received: from intranet.asianux.com ([58.214.24.6]:23594 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754542Ab2JPLnf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Oct 2012 07:43:35 -0400
Message-ID: <507D48A6.3070601@asianux.com>
Date: Tue, 16 Oct 2012 19:44:38 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [Bug fix] nfs-client: fix nfs_inode_attrs_need_update for async
 read_done comes during truncating to smaller size
References: <507B70F1.7040903@asianux.com> <4FA345DA4F4AE44899BD2B03EEEC2FA909236BB5@SACEXCMBX04-PRD.hq.netapp.com> <507B968A.9090104@asianux.com> <4FA345DA4F4AE44899BD2B03EEEC2FA90923F1C4@SACEXCMBX04-PRD.hq.netapp.com> <507CBA3F.6000204@asianux.com> <4FA345DA4F4AE44899BD2B03EEEC2FA909253103@SACEXCMBX04-PRD.hq.netapp.com> <507CDEF2.2060809@asianux.com> <20121016063348.7b225bfb@tlielax.poochiereds.net>
In-Reply-To: <20121016063348.7b225bfb@tlielax.poochiereds.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


于 2012年10月16日 18:33, Jeff Layton 写道:
> In any situation where we get back attributes, we have to decide
> whether they are valid or stale. It's always possible for replies or
> their handling to be reordered such that an older set of attributes
> is processed after a newer set.
> 
> Unfortunately, the v2/v3 protocols do not have great support for
> helping the client detect this situation, so we do the best we can with
> what we do have. Unfortunately when things are changing very quickly we
> can still get it wrong, especially with v2/3. [1]
> 
> In any case, the logic to determine this is in
> nfs_inode_attrs_need_update(). Looking at the size is sort of the "last
> resort" after we look at the timestamps and gencount.
> 

I agree with you (what I understood originally is just like what you
said above).

thank for your confirmation.

> The problem with doing what you suggest is that if we get it wrong, the
> consequences are worse than the file appearing to be bigger than it is.
> It means that written data may be silently lost.
> 

1) I understand why my suggestion is not quite suitable. I agree you.

2) but, are we truly no ways to solve this issue ?  (I do not think so).

3) I think an executable way (but maybe not a good way) is :

   A) for each client, check each task id of the client its own (such as
rpc task xid), so can know the order of tasks of the client its own.

   B) maybe also need another some synchronization code, but I think it
does not have much negative effect with performance.


> ======
> 
> [1]: v4 has a change attribute so it's slightly simpler there when the
> server supports it. Unrelated Q for Trond: should we be checking the v4
> change_attr in nfs_inode_attrs_need_update too? 

sorry for I am truly not quite familiar with nfs, I also think it is not
quite relative with current issue, so I have to skip it (although I
think these contents are valulable for Trond)

-- 
Chen Gang

Asianux Corporation

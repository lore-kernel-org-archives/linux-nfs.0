Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:57313 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab2KBEYJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2012 00:24:09 -0400
MIME-Version: 1.0
In-Reply-To: <CA+55aFxK+xr0Gc+ZLgi3Ch8YgoV78vvr+Q-7cP=kC7asFB5k5w@mail.gmail.com>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
 <20121030214257.GB2681@htj.dyndns.org> <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
 <1351646186.4004.41.camel@gandalf.local.home> <CA+55aFzFMrOUwdHHJ5-YUtEzTHGvdRosQc+K+trjub0K-w-D3A@mail.gmail.com>
 <CA+1xoqd8vAn+N1JuhpXRjSr74OPtnnw_1UBhf8=c4WDC3jOirw@mail.gmail.com> <CA+55aFxK+xr0Gc+ZLgi3Ch8YgoV78vvr+Q-7cP=kC7asFB5k5w@mail.gmail.com>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Fri, 2 Nov 2012 00:23:48 -0400
Message-ID: <CA+1xoqdu-ar=-hh-+uVPtj=jy=rN0OiOGr09OxZsyphYzyJuEw@mail.gmail.com>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
        mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com,
        ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org,
        eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com,
        axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de,
        ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com,
        bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com,
        venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com,
        edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 30, 2012 at 10:23 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Oct 30, 2012 at 6:36 PM, Sasha Levin <levinsasha928@gmail.com> wrote:
>>
>> I can either rebase that on top of mainline, or we can ask maintainers
>> to take it to their own trees if you take only 01/16 into mainline.
>> What would you prefer?
>
> I don't really care deeply. The only reason to merge it now would be
> to avoid any pain with it during the next merge window. Just taking
> 01/16 might be the sanest way to do that, then the rest can trickle in
> independently at their own leisure.

Okay, I'll keep working on converting everything else as soon as 01/16
makes it in your tree.


Thanks,
Sasha

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:53592 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762Ab2HOA2l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Aug 2012 20:28:41 -0400
Date: Tue, 14 Aug 2012 17:28:34 -0700
From: Tejun Heo <tj@kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: NeilBrown <neilb@suse.de>, torvalds@linux-foundation.org,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
        rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com,
        aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org,
        josh@joshtriplett.org, eric.dumazet@gmail.com,
        mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, ccaulfie@redhat.com, teigland@redhat.com,
        Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com,
        jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com,
        snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org,
        dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH 01/16] hashtable: introduce a small and naive hashtable
Message-ID: <20120815002834.GI25632@google.com>
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
 <1344961490-4068-2-git-send-email-levinsasha928@gmail.com>
 <20120815092523.00a909ef@notabene.brown>
 <502AEC51.2010305@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <502AEC51.2010305@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

(Sasha, would it be possible to change your MUA so that it breaks long
 lines.  It's pretty difficult to reply to.)

On Wed, Aug 15, 2012 at 02:24:49AM +0200, Sasha Levin wrote:
> The hashtable uses hlist. hlist provides us with an entire family of
> init functions which I'm supposed to use to initialize hlist heads.
> 
> So while a memset(0) will work perfectly here, I consider that
> cheating - it results in an uglier code that assumes to know about
> hlist internals, and will probably break as soon as someone tries to
> do something to hlist.

I think we should stick with INIT_HLIST_HEAD().  It's not a hot path
and we might add, say, debug fields or initialization magics added
later.  If this really matters, the right thing to do would be adding
something like INIT_HLIST_HEAD_ARRAY().

Thanks.

-- 
tejun

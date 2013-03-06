Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f50.google.com ([209.85.213.50]:53543 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501Ab3CFSxL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2013 13:53:11 -0500
Date: Wed, 6 Mar 2013 10:53:04 -0800
From: Tejun Heo <tj@kernel.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130306185304.GM1227@htj.dyndns.org>
References: <20130304205307.GA13527@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
 <20130305082308.6607d4db@tlielax.poochiereds.net>
 <20130305174648.GF12795@htj.dyndns.org>
 <20130305174954.GG12795@htj.dyndns.org>
 <20130305140312.243cb094@tlielax.poochiereds.net>
 <20130305190923.GI12795@htj.dyndns.org>
 <20130305183941.19ff39ce@tlielax.poochiereds.net>
 <20130305234700.GE1227@htj.dyndns.org>
 <20130306181608.GA18687@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130306181608.GA18687@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Oleg.

On Wed, Mar 06, 2013 at 07:16:08PM +0100, Oleg Nesterov wrote:
> And how SIGFREEZE can help? If we want to interrupt the sleeps in NFS/RPC
> layer we can simply add TASK_WAKEFREEZE (can be used with TASK_KILLABLE)
> and change freeze_task() to do signal_wake_up_state(TASK_WAKEFREEZE).

Oh yeah, we don't need another signal.  We just need sigpending state
and a wakeup.  I wasn't really going into details.  The important
point is that for code paths outside signal/ptrace, freezing could
look and behave about the same as signal delivery.

> But if we can do this, then it should be possible so simply make these
> sleeps TASK_INTERRUPTIBLE ? But it seems that we can't just because we
> can't always restart, so I am totally confused.

Of course, switching to another freezing mechanism doesn't make issues
like this go away in itself, but it would at least allow handling such
issues in easier to grasp way rather than dealing with this giant
pseudo lock and allows code paths outside jobctl to simply deal with
one issue - signal delivery, rather than having to deal with freezing
separately.  Also, while not completely identical, frozen state would
at least be an extension of jobctl trap and it would be possible to
allow things like killing frozen tasks or even ptracing them in
well-defined manner for cgroup_freezer use cases.  As it currently
stands, there is no well-defined abstraction for frozen state which we
can expose in any way, which sucks.

Thanks.

-- 
tejun

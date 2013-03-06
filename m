Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f178.google.com ([209.85.220.178]:35207 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288Ab3CFVAE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2013 16:00:04 -0500
MIME-Version: 1.0
In-Reply-To: <20130306185304.GM1227@htj.dyndns.org>
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
	<20130306185304.GM1227@htj.dyndns.org>
Date: Wed, 6 Mar 2013 13:00:02 -0800
Message-ID: <CA+55aFwDogteVd=vwGHXDSASnga-nZZnKaQz9aO1yBU2CPKSbA@mail.gmail.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
From: Linus Torvalds <torvalds@linux-foundation.org>
To: Tejun Heo <tj@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 6, 2013 at 10:53 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Oleg.
>
> On Wed, Mar 06, 2013 at 07:16:08PM +0100, Oleg Nesterov wrote:
>> And how SIGFREEZE can help? If we want to interrupt the sleeps in NFS/RPC
>> layer we can simply add TASK_WAKEFREEZE (can be used with TASK_KILLABLE)
>> and change freeze_task() to do signal_wake_up_state(TASK_WAKEFREEZE).
>
> Oh yeah, we don't need another signal.  We just need sigpending state
> and a wakeup.  I wasn't really going into details.  The important
> point is that for code paths outside signal/ptrace, freezing could
> look and behave about the same as signal delivery.

Don't we already do that? The whole "try_to_freeze()" in
get_signal_to_deliver() is about exactly this. See
fake_signal_wake_up().

You still have kernel threads (that don't do signals) to worry about,
so it doesn't make things go away. And you still have issues with
latency of disk wait, which is, I think, the reason for that
"freezable_schedule()" in the NFS code to begin with.

               Linus

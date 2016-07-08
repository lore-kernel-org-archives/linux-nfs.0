Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:34328 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755111AbcGHMv5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 08:51:57 -0400
Received: by mail-qk0-f171.google.com with SMTP id t127so36932568qkf.1
        for <linux-nfs@vger.kernel.org>; Fri, 08 Jul 2016 05:51:56 -0700 (PDT)
Message-ID: <1467982314.13822.5.camel@redhat.com>
Subject: Re: Hang due to nfs letting tasks freeze with locked inodes
From: Jeff Layton <jlayton@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Seth Forshee <seth.forshee@canonical.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho.andersen@canonical.com>
Date: Fri, 08 Jul 2016 08:51:54 -0400
In-Reply-To: <20160708122224.GA20200@dhcp22.suse.cz>
References: <20160706174655.GD45215@ubuntu-hedt>
	 <1467842838.2908.45.camel@redhat.com>
	 <20160708122224.GA20200@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-07-08 at 14:22 +0200, Michal Hocko wrote:
> On Wed 06-07-16 18:07:18, Jeff Layton wrote:
> > 
> > On Wed, 2016-07-06 at 12:46 -0500, Seth Forshee wrote:
> > > 
> > > We're seeing a hang when freezing a container with an nfs bind mount while
> > > running iozone. Two iozone processes were hung with this stack trace.
> > > 
> > >  [] schedule+0x35/0x80
> > >  [] schedule_preempt_disabled+0xe/0x10
> > >  [] __mutex_lock_slowpath+0xb9/0x130
> > >  [] mutex_lock+0x1f/0x30
> > >  [] do_unlinkat+0x12b/0x2d0
> > >  [] SyS_unlink+0x16/0x20
> > >  [] entry_SYSCALL_64_fastpath+0x16/0x71
> > > 
> > > This seems to be due to another iozone thread frozen during unlink with
> > > this stack trace:
> > > 
> > >  [] __refrigerator+0x7a/0x140
> > >  [] nfs4_handle_exception+0x118/0x130 [nfsv4]
> > >  [] nfs4_proc_remove+0x7d/0xf0 [nfsv4]
> > >  [] nfs_unlink+0x149/0x350 [nfs]
> > >  [] vfs_unlink+0xf1/0x1a0
> > >  [] do_unlinkat+0x279/0x2d0
> > >  [] SyS_unlink+0x16/0x20
> > >  [] entry_SYSCALL_64_fastpath+0x16/0x71
> > > 
> > > Since nfs is allowing the thread to be frozen with the inode locked it's
> > > preventing other threads trying to lock the same inode from freezing. It
> > > seems like a bad idea for nfs to be doing this.
> > > 
> > Yeah, known problem. Not a simple one to fix though.
> Apart from alternative Dave was mentioning in other email, what is the
> point to use freezable wait from this path in the first place?
> 
> nfs4_handle_exception does nfs4_wait_clnt_recover from the same path and
> that does wait_on_bit_action with TASK_KILLABLE so we are waiting in two
> different modes from the same path AFAICS. There do not seem to be other
> callers of nfs4_delay outside of nfs4_handle_exception. Sounds like
> something is not quite right here to me. If the nfs4_delay did regular
> wait then the freezing would fail as well but at least it would be clear
> who is the culrprit rather than having an indirect dependency.

The codepaths involved there are a lot more complex than that
unfortunately.

nfs4_delay is the function that we use to handle the case where the
server returns NFS4ERR_DELAY. Basically telling us that it's too busy
right now or has some transient error and the client should retry after
a small, sliding delay.

That codepath could probably be made more freezer-safe. The typical
case however, is that we've sent a call and just haven't gotten a
reply. That's the trickier one to handle.

-- 
Jeff Layton <jlayton@redhat.com>

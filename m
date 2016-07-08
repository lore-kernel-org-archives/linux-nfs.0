Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36315 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739AbcGHMW2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 08:22:28 -0400
Date: Fri, 8 Jul 2016 14:22:24 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Seth Forshee <seth.forshee@canonical.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: Hang due to nfs letting tasks freeze with locked inodes
Message-ID: <20160708122224.GA20200@dhcp22.suse.cz>
References: <20160706174655.GD45215@ubuntu-hedt>
 <1467842838.2908.45.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1467842838.2908.45.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 06-07-16 18:07:18, Jeff Layton wrote:
> On Wed, 2016-07-06 at 12:46 -0500, Seth Forshee wrote:
> > We're seeing a hang when freezing a container with an nfs bind mount while
> > running iozone. Two iozone processes were hung with this stack trace.
> > 
> >  [] schedule+0x35/0x80
> >  [] schedule_preempt_disabled+0xe/0x10
> >  [] __mutex_lock_slowpath+0xb9/0x130
> >  [] mutex_lock+0x1f/0x30
> >  [] do_unlinkat+0x12b/0x2d0
> >  [] SyS_unlink+0x16/0x20
> >  [] entry_SYSCALL_64_fastpath+0x16/0x71
> > 
> > This seems to be due to another iozone thread frozen during unlink with
> > this stack trace:
> > 
> >  [] __refrigerator+0x7a/0x140
> >  [] nfs4_handle_exception+0x118/0x130 [nfsv4]
> >  [] nfs4_proc_remove+0x7d/0xf0 [nfsv4]
> >  [] nfs_unlink+0x149/0x350 [nfs]
> >  [] vfs_unlink+0xf1/0x1a0
> >  [] do_unlinkat+0x279/0x2d0
> >  [] SyS_unlink+0x16/0x20
> >  [] entry_SYSCALL_64_fastpath+0x16/0x71
> > 
> > Since nfs is allowing the thread to be frozen with the inode locked it's
> > preventing other threads trying to lock the same inode from freezing. It
> > seems like a bad idea for nfs to be doing this.
> > 
> 
> Yeah, known problem. Not a simple one to fix though.

Apart from alternative Dave was mentioning in other email, what is the
point to use freezable wait from this path in the first place?

nfs4_handle_exception does nfs4_wait_clnt_recover from the same path and
that does wait_on_bit_action with TASK_KILLABLE so we are waiting in two
different modes from the same path AFAICS. There do not seem to be other
callers of nfs4_delay outside of nfs4_handle_exception. Sounds like
something is not quite right here to me. If the nfs4_delay did regular
wait then the freezing would fail as well but at least it would be clear
who is the culrprit rather than having an indirect dependency.
-- 
Michal Hocko
SUSE Labs

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50059 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753761Ab1IWQzo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 12:55:44 -0400
Date: Fri, 23 Sep 2011 12:55:13 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 4/6] leases: break read leases on rename
Message-ID: <20110923165510.GA807@pad.fieldses.org>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
 <1316617097-21384-5-git-send-email-bfields@redhat.com>
 <1316711869.3159.54.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1316711869.3159.54.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 22, 2011 at 01:17:49PM -0400, Mimi Zohar wrote:
> On Wed, 2011-09-21 at 10:58 -0400, J. Bruce Fields wrote: 
> > To rely on the i_mutex for exclusion between setlease and rename, we
> > need rename to take the i_mutex on the source as well as on any possible
> > target.
> > 
> > I suspect this is deadlock-free, but I need to think this proof through
> > again.  And I'm not sure what to do about lockdep.
> 
> Not sure that I will be of any help, but how about posting the lockdep
> messages?

Sure, appended below, but it's not particularly surprising--we're taking
i_mutex's on four different objects (both parents, source, and target if
any) where before there were three.

I suppose the solution is another i_mutex lock class, used only on the
lock of the source inode?

--b.

=============================================
[ INFO: possible recursive locking detected ]
3.1.0-rc1-00076-g0e7e722 #599
---------------------------------------------
mount/333 is trying to acquire lock:
(&sb->s_type->i_mutex_key#2){+.+.+.}, at: [<ffffffff811126d8>] vfs_rename+0x278/0x450
Sep 20 17:05:54 pip1 kernel:
but task is already holding lock:
(&sb->s_type->i_mutex_key#2){+.+.+.}, at: [<ffffffff81112b03>] sys_renameat+0x253/0x2d0
Sep 20 17:05:54 pip1 kernel:
other info that might help us debug this:
Possible unsafe locking scenario:
Sep 20 17:05:54 pip1 kernel:
      CPU0
      ----
 lock(&sb->s_type->i_mutex_key);
 lock(&sb->s_type->i_mutex_key);
Sep 20 17:05:54 pip1 kernel:
*** DEADLOCK ***
Sep 20 17:05:54 pip1 kernel:
May be due to missing lock nesting notation
Sep 20 17:05:54 pip1 kernel:
2 locks held by mount/333:
#0: (&sb->s_type->i_mutex_key#2/1){+.+.+.}, at: [<ffffffff8110efc8>] lock_rename+0xe8/0xf0
#1:  (&sb->s_type->i_mutex_key#2){+.+.+.}, at: [<ffffffff81112b03>] sys_renameat+0x253/0x2d0
Sep 20 17:05:54 pip1 kernel:
stack backtrace:
Pid: 333, comm: mount Not tainted 3.1.0-rc1-00076-g0e7e722 #599
Call Trace:
[<ffffffff8107c9df>] __lock_acquire+0x15bf/0x1d80
[<ffffffff811126d8>] ?  vfs_rename+0x278/0x450
[<ffffffff8107d794>] lock_acquire+0x94/0x140
[<ffffffff811126d8>] ?  vfs_rename+0x278/0x450
[<ffffffff811126d8>] ?  vfs_rename+0x278/0x450
[<ffffffff81979d7f>] mutex_lock_nested+0x4f/0x360
[<ffffffff811126d8>] ?  vfs_rename+0x278/0x450
[<ffffffff8103b2b1>] ?  get_parent_ip+0x11/0x50
[<ffffffff8197ed9d>] ?  sub_preempt_count+0x9d/0xd0
[<ffffffff811126d8>] vfs_rename+0x278/0x450
[<ffffffff8103b2b1>] ?  get_parent_ip+0x11/0x50
[<ffffffff81112b5d>] sys_renameat+0x2ad/0x2d0
[<ffffffff810edab3>] ? remove_vma+0x53/0x70
[<ffffffff81079b0d>] ?  trace_hardirqs_on_caller+0xfd/0x190
[<ffffffff81079bad>] ?  trace_hardirqs_on+0xd/0x10
[<ffffffff810edab3>] ? remove_vma+0x53/0x70
[<ffffffff81982998>] ?  sysret_check+0x26/0x60
[<ffffffff81079b0d>] ?  trace_hardirqs_on_caller+0xfd/0x190
[<ffffffff81112b9b>] sys_rename+0x1b/0x20
[<ffffffff81982968>] system_call_fastpath+0x16/0x1b


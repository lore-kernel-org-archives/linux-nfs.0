Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36271 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373AbbL0Cyo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 21:54:44 -0500
Received: by mail-ob0-f174.google.com with SMTP id ba1so122943716obb.3
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 18:54:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151227022831.GF20997@ZenIV.linux.org.uk>
References: <1451046656-26319-1-git-send-email-buczek@molgen.mpg.de>
	<CAHQdGtSCn4bbx4xiyE7FXmWk3SCY81mvWLJz_1VDow9YtB5VgA@mail.gmail.com>
	<567F29A7.2020906@molgen.mpg.de>
	<CAHQdGtSUmwVv0Do6Gu5=x+BonsoAi4afo_RzOo8KG+wp75t4aw@mail.gmail.com>
	<20151227003837.GE20997@ZenIV.linux.org.uk>
	<CAHQdGtQPGp10hLfEPRG6cq0HmXgNheUhXe+Y+7w0kLRh5+rLig@mail.gmail.com>
	<20151227022831.GF20997@ZenIV.linux.org.uk>
Date: Sat, 26 Dec 2015 21:54:43 -0500
Message-ID: <CAHQdGtR1xE1dxjrBSGNY4hn6qKpmAhd+DAX=z=53mN0V84FiyQ@mail.gmail.com>
Subject: Re: [PATCH] nfs: do not deny execute access based on outdated mode in inode
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Donald Buczek <buczek@molgen.mpg.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 26, 2015 at 9:28 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sat, Dec 26, 2015 at 08:26:13PM -0500, Trond Myklebust wrote:
>
>> The may_open() is now happening before NFS gets a chance to issue the
>> OPEN rpc call, which is a change w.r.t. the lookup intent code. The
>> ordering is significant because it means the OPEN can no longer prime
>>  the access cache.
>
> Always had...  Consider e.g. device nodes; there ->open() might very well
> have side effects, and ones you do not want to allow for any random caller.
> Permissions checks always had been done prior to ->open(), it's not something
> new.

When we did lookup intents, the d_revalidate() would take a lookup
intent, which would trigger the OPEN call for NFS before we got
anywhere near permissions checking. As I said, the removal of lookup
intents makes that impossible, and hence now we have the inefficiency.

>
>> >> > Merry Christmas
>> >>
>> >> Suggestions Al?
>> >
>> > Make nfs_permission() relax the checks when it sees MAY_OPEN, if you know
>> > that things will be caught by server anyway?
>>
>> That can work as long as we're guaranteed that everything that calls
>> inode_permission() with MAY_OPEN on a regular file will also follow up
>> with a vfs_open() or dentry_open() on success. Is this always the
>> case?
>
> 1) in do_tmpfile(), followed by do_dentry_open() (not reachable by NFS since
> it doesn't have ->tmpfile() instance anyway)
>
> 2) in atomic_open(), after the call of ->atomic_open() has succeeded.

Right, so we don't care there either.

> 3) in do_last(), followed on success by vfs_open()
>
> That's all.  All calls of inode_permission() that get MAY_OPEN come from
> may_open(), and there's no other callers of that puppy.

OK.

> PS: I'm not sure we want to carry that MAY_OPEN in op->acc_mode, actually.
> may_open() gets acc_mode without MAY_OPEN only when called from do_last()
> in case of O_PATH open.  The check in the very beginning of may_open()
> triggers only in that case and might as well be replaced with
>         if (likely(!(open_flag & O_PATH))) {
>                 error = may_open(&nd->path, acc_mode, open_flag);
>                 if (error)
>                         goto out;
>         }
> in that call site (one right after finish_open_created:).  Then we could
> bloody well have may_open() do
>         error = inode_permission(inode, acc_mode | MAY_OPEN);
> and forget about MAY_OPEN in op->acc_mode.
>
> Something like the patch below should be an equivalent transformation and with
> that it's really clear what's going on with MAY_OPEN.  Warning: completely
> untested.

That looks right and would indeed make it easier to trace. I'll push
the changes to nfs_permission()

Thanks!
  Trond

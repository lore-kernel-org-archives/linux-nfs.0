Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33081 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031AbbL0B0O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 20:26:14 -0500
Received: by mail-oi0-f49.google.com with SMTP id y66so160426124oig.0
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 17:26:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151227003837.GE20997@ZenIV.linux.org.uk>
References: <1451046656-26319-1-git-send-email-buczek@molgen.mpg.de>
	<CAHQdGtSCn4bbx4xiyE7FXmWk3SCY81mvWLJz_1VDow9YtB5VgA@mail.gmail.com>
	<567F29A7.2020906@molgen.mpg.de>
	<CAHQdGtSUmwVv0Do6Gu5=x+BonsoAi4afo_RzOo8KG+wp75t4aw@mail.gmail.com>
	<20151227003837.GE20997@ZenIV.linux.org.uk>
Date: Sat, 26 Dec 2015 20:26:13 -0500
Message-ID: <CAHQdGtQPGp10hLfEPRG6cq0HmXgNheUhXe+Y+7w0kLRh5+rLig@mail.gmail.com>
Subject: Re: [PATCH] nfs: do not deny execute access based on outdated mode in inode
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Donald Buczek <buczek@molgen.mpg.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 26, 2015 at 7:38 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sat, Dec 26, 2015 at 07:11:16PM -0500, Trond Myklebust wrote:
>
>> Ah... IOW: That so called "fast path" crap in do_last() is screwing us
>> over by forcing us to to 2 ACCESS calls. The first being done for no
>> good reason by the VFS, and the second being done in the OPEN call to
>> the server in the NFS client.
>
> Excuse me, but this is complete BS.  First of all, are you suggesting
> that every filesystem out there must push the permission checks into
> its ->open()?  This may_open() is where they normally happen...
>
> Moreover, the things like "this mount is r/o, don't let anything to
> be opened on it" are inherently client-side.  It's a property of
> vfsmount; the same fs instance might be accessible r/w in another
> place.  And things like opening a device node, etc. are not reaching
> the server at all.

The may_open() is now happening before NFS gets a chance to issue the
OPEN rpc call, which is a change w.r.t. the lookup intent code. The
ordering is significant because it means the OPEN can no longer prime
the access cache.

>> > Merry Christmas
>>
>> Suggestions Al?
>
> Make nfs_permission() relax the checks when it sees MAY_OPEN, if you know
> that things will be caught by server anyway?

That can work as long as we're guaranteed that everything that calls
inode_permission() with MAY_OPEN on a regular file will also follow up
with a vfs_open() or dentry_open() on success. Is this always the
case?

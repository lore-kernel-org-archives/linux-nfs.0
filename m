Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f53.google.com ([209.85.212.53]:37468 "EHLO
	mail-vb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528Ab3HBSAK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Aug 2013 14:00:10 -0400
Received: by mail-vb0-f53.google.com with SMTP id i3so910563vbh.40
        for <linux-nfs@vger.kernel.org>; Fri, 02 Aug 2013 11:00:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375314445.14217.53.camel@leira.trondhjem.org>
References: <20130731230051.GB31859@gmail.com>
	<1375314445.14217.53.camel@leira.trondhjem.org>
Date: Fri, 2 Aug 2013 13:00:09 -0500
Message-ID: <CAKjHkpBux8Hpg+gPc9m=BG15+GBWn5drLG5p=RMS2cEU_iXFyQ@mail.gmail.com>
Subject: Re: [PATCH] nfs: don't allow nfs_find_actor to match inodes of the
 wrong type
From: Quentin Barnes <qbarnes@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 31, 2013 at 6:47 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2013-07-31 at 18:00 -0500, Quentin Barnes wrote:
>> > Quite frankly, all I care about in a situation like this is that the
>> > client doesn't Oops.
>>
>> Certainly, and his patch does do that, but it's also pointing out
>> there's another bug running around.  And once you fix that bug, the
>> original patch is no longer needed.
>>
>> > If a server is really this utterly broken, then there is no way we can
>> > fix it on the client, and we're not even going to try.
>>
>> Of course.  But you also don't want to unnecessarily leave the
>> client with an invalid inode that's not properly flagged and
>> possibly leave another bug unfixed.
>
> Why is the invalid inode not being flagged a problem that needs to be
> solved?
> How does the patch that you've proposed change matters for the end user
> or application?

Ah, good questions!  Let's see if I can address them to your satisfaction.

> Why is the invalid inode not being flagged a problem that needs to be
> solved?

It's giving nfs_refresh_inode_locked() a consistent behavior.

If nfs_refresh_inode_locked() has two paths depending on if
nfs_inode_attrs_need_update() happens to be true or not,
calling either nfs_update_inode() or nfs_check_inode_attributes().

If nfs_refresh_inode_locked() happens to go down the
nfs_update_inode() [which could simply be due to nothing other than
timing], the problem of having an NFS server reusing a file handle
would be caught, the inode flagged, and the error bubbled up to the
caller.

However, without the proposed change, if the path taken is to
nfs_check_inode_attributes(), the error it caught is silently
ignored (which I assert led to Benny's reported panic).

> How does the patch that you've proposed change matters for the end user
> or application?

With the original patch, user space could either get back from a
syscall on the file either a failure or success depending on how or
when the nfs subsystem noticed that the NFS server had reused a file
handle.

With the new patch, user space will consistently always get a failure.

> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f171.google.com ([209.85.220.171]:48026 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbbANQVm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 11:21:42 -0500
Received: by mail-vc0-f171.google.com with SMTP id hy4so3147163vcb.2
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 08:21:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQAqn9zh8UC-dn2s3nLmnRyyxeSNdk=+FZdYmj46ZEcXA@mail.gmail.com>
References: <1421244543-32539-1-git-send-email-tao.peng@primarydata.com>
	<20150114154838.GA15323@infradead.org>
	<CAHQdGtQAqn9zh8UC-dn2s3nLmnRyyxeSNdk=+FZdYmj46ZEcXA@mail.gmail.com>
Date: Wed, 14 Jan 2015 11:21:41 -0500
Message-ID: <CAHQdGtQspcenaCgrFeeJ6QSvOiji=bTBFksCr9T6k97tWF6GsQ@mail.gmail.com>
Subject: Re: [PATCH] nfs: fix dio deadlock when O_DIRECT flag is flipped
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Peng Tao <tao.peng@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Omar Sandoval <osandov@osandov.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Resend for the benefit of the f*ing mailing list spam filter...

On Wed, Jan 14, 2015 at 11:20 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
>
>
>
> On Wed, Jan 14, 2015 at 10:48 AM, Christoph Hellwig <hch@infradead.org> wrote:
>>
>> On Wed, Jan 14, 2015 at 10:09:03PM +0800, Peng Tao wrote:
>> > Running xfstest generic/036, we'll get following VM_BUG_ON in
>> > nfs_direct_IO(). 036 toggles O_DIRECT flag while IO is going on.
>> > So the VM_BUG_ON should not exist there. However, we have a deadlock
>> > in the code path as well, because inode->i_mutex is taken when calling
>> > into ->direct_IO. And nfs_file_direct_write() would grab inode->i_mutex
>> > again.
>> >
>> > Meanwhile, nfs_file_direct_write() does a lot of things that is already
>> > done by vfs before ->direct_IO is called. So skip those duplicates. One
>> > exception is i_size_write. vfs does not take i_lock when setting i_size.
>> > But nfs appears to need i_lock when setting i_size.
>>
>> But given that NFS implements direct I/O without ->direct_IO (except for
>> the horrible swap over NFS hack that is on it's way out) it shold
>> never be called.
>>
>> The right fix is to determine the O_DIRECT flag in one place when
>> entering a write, and then pass it down on the stack.  We already do
>> this in XFS for example, it just needs to be expanded to filemap.c
>> so that more filesystems benefit from it.
>
>
> Can't we just assume that anything that calls nfs_direct_IO() on a file for which !IS_SWAPFILE(inode) is actually doing the xfstests O_DIRECT flag flipping dance, and just return the value '0'?
>
> AFAICT that should cause both generic_file_read_iter() and generic_file_write_iter() to fall back to buffered I/O, which is what we want...
>
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com




-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:47207 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551AbbANQz4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 11:55:56 -0500
Received: by mail-qa0-f46.google.com with SMTP id j7so7421571qaq.5
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 08:55:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150114154838.GA15323@infradead.org>
References: <1421244543-32539-1-git-send-email-tao.peng@primarydata.com> <20150114154838.GA15323@infradead.org>
From: Peng Tao <tao.peng@primarydata.com>
Date: Thu, 15 Jan 2015 00:55:35 +0800
Message-ID: <CAKVebiUx+WMku--vyRC5h6-8vZ27vOoqVVyfpEmwztJaqvAx9g@mail.gmail.com>
Subject: Re: [PATCH] nfs: fix dio deadlock when O_DIRECT flag is flipped
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 14, 2015 at 11:48 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Jan 14, 2015 at 10:09:03PM +0800, Peng Tao wrote:
>> Running xfstest generic/036, we'll get following VM_BUG_ON in
>> nfs_direct_IO(). 036 toggles O_DIRECT flag while IO is going on.
>> So the VM_BUG_ON should not exist there. However, we have a deadlock
>> in the code path as well, because inode->i_mutex is taken when calling
>> into ->direct_IO. And nfs_file_direct_write() would grab inode->i_mutex
>> again.
>>
>> Meanwhile, nfs_file_direct_write() does a lot of things that is already
>> done by vfs before ->direct_IO is called. So skip those duplicates. One
>> exception is i_size_write. vfs does not take i_lock when setting i_size.
>> But nfs appears to need i_lock when setting i_size.
>
> But given that NFS implements direct I/O without ->direct_IO (except for
> the horrible swap over NFS hack that is on it's way out) it shold
> never be called.
>
036 flips O_DIRECT flag with fcntl. So in theory user space is able to
hit the VM_BUG_ON().

> The right fix is to determine the O_DIRECT flag in one place when
> entering a write, and then pass it down on the stack.  We already do
> this in XFS for example, it just needs to be expanded to filemap.c
> so that more filesystems benefit from it.
NFS hijacks DIO in ->write_iter by checking O_DIRECT flag and rely on
generic_file_write_iter() for buffer write. generic_file_write_iter()
again checks for O_DIRECT flag.... It seems that we can avoid the
double check on O_DIRECT flag by calling generic_perform_write()
instead.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:64285 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbaIEBw0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 21:52:26 -0400
Received: by mail-vc0-f180.google.com with SMTP id lf12so11345036vcb.25
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 18:52:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <584874869.387720.1409869399398.JavaMail.zimbra@xes-inc.com>
References: <2124227602.386654.1409868802614.JavaMail.zimbra@xes-inc.com>
	<584874869.387720.1409869399398.JavaMail.zimbra@xes-inc.com>
Date: Thu, 4 Sep 2014 21:52:25 -0400
Message-ID: <CAHQdGtT3iwdTXB3ecKSbao=yErOzv8NREPta1A5mOtwYxmRb8Q@mail.gmail.com>
Subject: Re: Clarification on client "async" option
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andrew Martin <amartin@xes-inc.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 4, 2014 at 6:23 PM, Andrew Martin <amartin@xes-inc.com> wrote:
> Hello,
>
> I would like to understand in more detail how the client-side "async" option
> works with NFSv3 when used with the NFSv3 server-side option "sync" (async on
> the client, sync on the server). According to the manpage:
>
>>       The NFS client treats the sync mount option differently than some other
>> file systems (refer to mount(8) for a description of the generic sync and async
>> mount options).  If neither sync nor async is specified (or if the async option
>> is specified), the NFS client delays sending application writes to the server
>> until any of these  events occur:
>>
>>              Memory pressure forces reclamation of system memory resources.
>>
>>              An application flushes file data explicitly with sync(2),
>>              msync(2), or fsync(3).
>>
>>              An application closes a file with close(2).
>>
>>              The file is locked/unlocked via fcntl(2).
>
>
> When performing a sample strace, e.g with rsync:
> strace -f rsync -av hosts /mn/nfs/dest
>
> I see the following:
> [pid 10670] read(3, "127.0.0.1\tlocalhost\n#127.0.1.1\tv"..., 350) = 350
> [pid 10670] close(3)                    = 0
> [pid 10670] select(5, NULL, [4], [4], {60, 0}) = 1 (out [4], left {59, 999998})
> [pid 10670] write(4, "\211\1\0\7\2\0\240\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0^\1\0\000127.0"..., 397 <unfinished ...>
> [pid 10672] <... select resumed> )      = 1 (in [0], left {59, 999185})
> [pid 10670] <... write resumed> )       = 397
> [pid 10672] read(0,  <unfinished ...>
> [pid 10670] select(6, [5], [], NULL, {60, 0} <unfinished ...>
> [pid 10672] <... read resumed> "\211\1\0\7", 4) = 4
> [pid 10672] select(1, [0], [], NULL, {60, 0}) = 1 (in [0], left {59, 999998})
> [pid 10672] read(0, "\2\0\240\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0^\1\0\000127.0.0.1"..., 393) = 393
> [pid 10672] open("dest", O_RDONLY)      = -1 ENOENT (No such file or directory)
> [pid 10672] open(".dest.y4ihWF", O_RDWR|O_CREAT|O_EXCL, 0600) = 1
> [pid 10672] fchmod(1, 0600)             = 0
> [pid 10672] mmap(NULL, 266240, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f7c28b49000
> [pid 10672] write(1, "127.0.0.1\tlocalhost\n#127.0.1.1\tv"..., 350) = 350
> [pid 10672] close(1)                    = 0
> [pid 10672] lstat(".dest.y4ihWF", {st_mode=S_IFREG|0600, st_size=350, ...}) = 0
> [pid 10672] utimensat(AT_FDCWD, ".dest.y4ihWF", {UTIME_NOW, {1357852439, 0}}, AT_SYMLINK_NOFOLLOW) = 0
> [pid 10672] chmod(".dest.y4ihWF", 0644) = 0
> [pid 10672] rename(".dest.y4ihWF", "dest") = 0
>
> This shows that a temporary filename is written and then closed, however the
> file is then chmodded and renamed to the final destination filename. Do the
> chmod(2) and rename(2) calls force a COMMIT to be sent, flushing these changes
> to stable storage on the NFS server? Or, is there a possibility that during a
> power failure of both client and server, the file would remain as .dest.y4ihWF
> on the server?

In NFSv3, the close() will cause the client to flush all data to stable storage.
The client will also flush data to stable storage on a chmod, since
that could potentially affect its ability to write back the data. It
will not bother to do so for rename.
An application should normally be able to rely on the data being
safely on disk in both these situations provided that the server
honours the NFS protocol (with a caveat that an ill-timed 'kill -9'
could interrupt the process of flushing).

All metadata operations such as create, chmod, rename, etc. will cause
the server to flush the file metadata to disk assuming that you set
the (highly recommended) "sync" export option. If "sync" is set, the
server will also honour COMMIT requests by flushing the data to stable
storage.
If, OTOH, your server lists the "async" export option as being set,
then COMMIT is considered a no-op, and it will not bother to
explicitly flush metadata operations to stable storage. Performance
will scream, but be prepared to lose data if that server crashes. This
is all technically a violation of the NFS spec, however you have been
given rope...

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

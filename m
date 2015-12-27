Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:35347 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbbL0QX4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Dec 2015 11:23:56 -0500
Received: by mail-ob0-f182.google.com with SMTP id 18so221383546obc.2
        for <linux-nfs@vger.kernel.org>; Sun, 27 Dec 2015 08:23:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <567FD72A.7090903@molgen.mpg.de>
References: <CAHQdGtR1xE1dxjrBSGNY4hn6qKpmAhd+DAX=z=53mN0V84FiyQ@mail.gmail.com>
	<1451185588-69667-1-git-send-email-trond.myklebust@primarydata.com>
	<567FD72A.7090903@molgen.mpg.de>
Date: Sun, 27 Dec 2015 11:23:55 -0500
Message-ID: <CAHQdGtRSPrV=eV_VEGbpp47qfpW93GSouoEzaseHDq5enMtCDg@mail.gmail.com>
Subject: Re: [PATCH] NFSv4: Don't perform cached access checks before we've
 OPENed the file
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Donald Buczek <buczek@molgen.mpg.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 27, 2015 at 7:18 AM, Donald Buczek <buczek@molgen.mpg.de> wrote:
>
>
> On 27.12.2015 04:06, Trond Myklebust wrote:
>>
>> Donald Buczek reports that a nfs4 client incorrectly denies
>> execute access based on outdated file mode (missing 'x' bit).
>> After the mode on the server is 'fixed' (chmod +x) further execution
>> attempts continue to fail, because the nfs ACCESS call updates
>> the access parameter but not the mode parameter or the mode in
>> the inode.
>>
>> The root cause is ultimately that the VFS is calling may_open()
>> before the NFS client has a chance to OPEN the file and hence revalidate
>> the access and attribute caches.
>>
>> Al Viro suggests:
>>>>>
>>>>> Make nfs_permission() relax the checks when it sees MAY_OPEN, if you
>>>>> know
>>>>> that things will be caught by server anyway?
>>>>
>>>> That can work as long as we're guaranteed that everything that calls
>>>> inode_permission() with MAY_OPEN on a regular file will also follow up
>>>> with a vfs_open() or dentry_open() on success. Is this always the
>>>> case?
>>>
>>> 1) in do_tmpfile(), followed by do_dentry_open() (not reachable by NFS
>>> since
>>> it doesn't have ->tmpfile() instance anyway)
>>>
>>> 2) in atomic_open(), after the call of ->atomic_open() has succeeded.
>>>
>>> 3) in do_last(), followed on success by vfs_open()
>>>
>>> That's all.  All calls of inode_permission() that get MAY_OPEN come from
>>> may_open(), and there's no other callers of that puppy.
>>
>> Reported-by: Donald Buczek <buczek@molgen.mpg.de>
>> Link: https://bugzilla.kernel.org/show_bug.cgi?id=109771
>> Link:
>> http://lkml.kernel.org/r/1451046656-26319-1-git-send-email-buczek@molgen.mpg.de
>> Cc: Al Viro <viro@zeniv.linux.org.uk>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> Hi Donald,
>> Can you check if this fixes the issue for you?
>>
>>   fs/nfs/dir.c | 3 +++
>>   1 file changed, 3 insertions(+)
>>
>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>> index ce5a21861074..44e519c21e18 100644
>> --- a/fs/nfs/dir.c
>> +++ b/fs/nfs/dir.c
>> @@ -2449,6 +2449,9 @@ int nfs_permission(struct inode *inode, int mask)
>>                 case S_IFLNK:
>>                         goto out;
>>                 case S_IFREG:
>> +                       if ((mask & MAY_OPEN) &&
>> +                          nfs_server_capable(inode, NFS_CAP_ATOMIC_OPEN))
>> +                               return 0;
>>                         break;
>>                 case S_IFDIR:
>>                         /*
>
>
>
> I can confirm that this fixes the original issue. However, even with this
> patch, calls to the access syscall would continue to deliver failure based
> on obsolete modes forever. This can be seen as a bug, too.

No. What happens now is that the OPEN compound executes before any
ACCESS calls, and so it refreshes the inode attributes and the access
cache.

> PS:
>
> I don't yet understand the point of execute_ok. It doesn't even consider the
> uid.

...or the group ownership or anything other than whether or not at
least one execute bit is set. That's a convention that was set in the
VFS a long time ago, and that Miklos' patches later pushed down into
the filesystems.
I'm OK with removing it, if someone can explain to me what it was
intended to enforce in the first place, so that we can have a
discussion about why it may be obsolete.

> Apart from that two suggestions to consider:
>
>   * If we go over the server for ACCESS anyway, we could combine it with a
> GETATTR compound operation. Then we would be ready for additional
> client-side checks against the inode.
>
>   * If we look at the mode, we should validate it first (
> nfs_revalidate_inode ? )

For regular files, we now only go to the server for ACCESS if we're
holding a delegation, in which case we already know the values for the
attributes; the client is authoritative in that case.

Cheers
  Trond

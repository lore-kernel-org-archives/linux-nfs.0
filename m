Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:55822 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756395Ab1LOX3n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2011 18:29:43 -0500
Message-ID: <4EEA826D.2070200@oracle.com>
Date: Thu, 15 Dec 2011 15:27:41 -0800
From: Maxim Uvarov <maxim.uvarov@oracle.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Al Viro <viro@ZenIV.linux.org.uk>, linux-nfs@vger.kernel.org,
        bfields@fieldses.org, john@johnmccutchan.com, rlove@rlove.org,
        eparis@parisplace.org
Subject: Re: [PATCH] NFS/INOTIFY: inotify user when deleting files on nfs
References: <1323903495-4084-1-git-send-email-maxim.uvarov@oracle.com> <1323903495-4084-2-git-send-email-maxim.uvarov@oracle.com> <20111214232254.GP2203@ZenIV.linux.org.uk> <4EEA469E.6070307@oracle.com> <20111215213256.GS2203@ZenIV.linux.org.uk> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C863704@SACMVEXC2-PRD.hq.netapp.com> <4EEA75DD.9080601@oracle.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C863744@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C863744@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/15/2011 02:58 PM, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: Maxim Uvarov [mailto:maxim.uvarov@oracle.com]
>> Sent: Thursday, December 15, 2011 5:34 PM
>> To: Myklebust, Trond
>> Cc: Al Viro; linux-nfs@vger.kernel.org; bfields@fieldses.org;
>> john@johnmccutchan.com; rlove@rlove.org; eparis@parisplace.org
>> Subject: Re: [PATCH] NFS/INOTIFY: inotify user when deleting files on
> nfs
>>
>> On 12/15/2011 01:52 PM, Myklebust, Trond wrote:
>>>> -----Original Message-----
>>>> From: Al Viro [mailto:viro@ZenIV.linux.org.uk]
>>>> Sent: Thursday, December 15, 2011 4:33 PM
>>>> To: Maxim Uvarov
>>>> Cc: linux-nfs@vger.kernel.org; bfields@fieldses.org; Myklebust,
>>>> Trond; john@johnmccutchan.com; rlove@rlove.org;
>> eparis@parisplace.org
>>>> Subject: Re: [PATCH] NFS/INOTIFY: inotify user when deleting files
> on
>>> nfs
>>>>
>>>> On Thu, Dec 15, 2011 at 11:12:30AM -0800, Maxim Uvarov wrote:
>>>>
>>>>> 1. Original VFS code already has "if NFS", in vfs_unlink().
> Because
>>> of
>>>>> code does not call d_delete() it has to call notification from
>>>>> d_delete().
>>>>>
>>>>> 2. inotify is done on VFS layer. So logically it has to work on
> all
>>>>> file systems.
>>>>
>>>> You are using a very odd meaning of the word "logically", then.
> Note
>>> that
>>>> inotify does *not* work on NFS, no matter what vfs_unlink() would
> do.
>>>> Simply because files are removed on server, not in VFS.  And server
>>> does not
>>>> notify clients of such removals.  Ergo, any software that relies on
>>> inotify
>>>> delivering notifications of files being removed is broken on NFS.
>>>> That has nothing whatsoever to the layer in kernel where it's
>>>> handled;
>>> the
>>>> information asked for is simply not available to client.  Period.
>>>>
>>>> Incidentally, inotify does not work on a bunch of local
> filesystems,
>>> starting
>>>> with procfs.  And won't work, unless you are seriously proposing to
>>> generate
>>>> events on things like open()/dup2()/etc.  In this case we might
> very
>>> well have
>>>> objects appearing and disappearing without ever having had a
> dentry.
>>>
>>> The other thing to note is that even if there were value in having
>>> only client support for the locally performed operations, the way
> NFS
>>> deletes work is fundamentally different to the way that POSIX unlink
>>> works: if the file is still open, it isn't deleted, it is just
>>> renamed. In consequence, it not only still appears in readdir()
>>> requests (albeit under a different name), but it acts in all ways
>>> shapes and forms as the same regular file but with the curious
>>> property that when the last user closes it gets deleted.
>>>
>>> IOW: the assumption that we would need to generate an
>>> fsnotify_nameremove event here is in any case flawed. It would
> rather
>>> be fsnotify_move, which I suspect would still trip up these LTP
> tests...
>>>
>>> Cheers
>>>      Trond
>>>
>>
>> Thanks. My original idea was to generate absolutely the same event
> under
>> unlink(). Yes, original file in that case is not deleted, it is moved.
>> But from user side it's deletion. Users don't take care about
> /tmp/.nfs..  files,
>> right? When you call unlink the only thing you do is to check return
> code, you
>> are not walking along all folders to check where it could be moved.
>
> It is not deletion because it is not an atomic operation.
>
> Until the last close occurs. ls -a will still list the .nfsxxxx entry.
> Most operations that the user may expect to fail on a deleted file such
> as link(), open(), access(), stat(), etc. will still succeed provided
> that you use the .nfsxxxx name. On the other hand, an operation such as
> rmdir() on the parent directory will not succeed because it still
> contains at least one file entry...
>
>> I also agree that if server or other mounts does something with file,
> server
>> will not send any notification. But for single mount it has to be ok.
>
> What's the killer application?
>
No application, I only have information that one of LTP tests is failed.

Maxim.


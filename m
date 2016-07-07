Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:42136 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752844AbcGGVxB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2016 17:53:01 -0400
Subject: Re: [PATCH 1/2] nfs: Fix spurios EPERM when mkdir of existing dentry
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <4D9E1AEE-D37F-43D8-8F22-E66572388CB8@primarydata.com>
Date: Thu, 7 Jul 2016 17:52:47 -0400
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Viro Alexander <viro@ZenIV.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <1DFC2ADD-11BF-43E6-8229-3F266FE3ABF5@linuxhacker.ru>
References: <1467870827-2959489-1-git-send-email-green@linuxhacker.ru> <1467870827-2959489-2-git-send-email-green@linuxhacker.ru> <9F6E5530-CBA4-4A0A-BAE1-72AAC28DB4D1@primarydata.com> <F3D54183-12C6-458F-B4DB-05016EAA6272@linuxhacker.ru> <0438AC35-50AD-4D9E-9C23-7EED70EF2B4C@primarydata.com> <F6721966-DE36-44B1-8935-A01132B4C62F@linuxhacker.ru> <4D9E1AEE-D37F-43D8-8F22-E66572388CB8@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 7, 2016, at 1:27 PM, Trond Myklebust wrote:

> 
>> On Jul 7, 2016, at 13:07, Oleg Drokin <green@linuxhacker.ru> wrote:
>> 
>> 
>> On Jul 7, 2016, at 12:59 PM, Trond Myklebust wrote:
>> 
>>> 
>>>> On Jul 7, 2016, at 12:52, Oleg Drokin <green@linuxhacker.ru> wrote:
>>>> 
>>>> 
>>>> On Jul 7, 2016, at 12:16 PM, Trond Myklebust wrote:
>>>> 
>>>>> 
>>>>>> On Jul 7, 2016, at 01:53, Oleg Drokin <green@linuxhacker.ru> wrote:
>>>>>> 
>>>>>> It's great when we can shave an extra RPC, but not at the expense
>>>>>> of correctness.
>>>>>> We should not return EPERM (from vfs_create/mknod/mkdir) if the
>>>>>> name already exists, even if we have no write access in parent.
>>>>>> 
>>>>>> Since the check in nfs_permission is clearly not enough to stave
>>>>>> off this, just throw in the extra READ access to actually
>>>>>> go through.
>>>>>> 
>>>>>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>>>>>> ---
>>>>>> fs/nfs/dir.c | 4 +++-
>>>>>> 1 file changed, 3 insertions(+), 1 deletion(-)
>>>>>> 
>>>>>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>>>>>> index d8015a0..8c7835b 100644
>>>>>> --- a/fs/nfs/dir.c
>>>>>> +++ b/fs/nfs/dir.c
>>>>>> @@ -1383,8 +1383,10 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
>>>>>> 	/*
>>>>>> 	 * If we're doing an exclusive create, optimize away the lookup
>>>>>> 	 * but don't hash the dentry.
>>>>>> +	 * This optimization only works if we can write in the parent.
>>>>>> 	 */
>>>>>> -	if (nfs_is_exclusive_create(dir, flags))
>>>>>> +	if (nfs_is_exclusive_create(dir, flags) &&
>>>>>> +	    (inode_permission(dir, MAY_WRITE | MAY_READ | MAY_EXEC) == 0))
>>>>>> 		return NULL;
>>>>>> 
>>>>> 
>>>>> NACK. The only write permission we should care about on the client side is whether or not the filesystem is mounted read-only. All other permissions are checked by the server.
>>>> 
>>>> Right. This was mostly a discussion piece.
>>>> The problem here is nfs_permission() returns 0 if you check for
>>>> inode_permission(dir, MAY_WRITE | MAY_EXEC) (as in may_create), but then
>>>> some other checks in the kernel still catch on to the fact that the directory
>>>> is not writeable, so we have a premature failure with EPERM and server never sees
>>>> this request which breaks things.
>>> 
>>> Are these VFS level checks? Which ones?
>> 
>> Yes, VFS level I believe.
>> For Lustre it's may_create() from vfs_mkdir() that stops us short
>> and the Lustre patch is effective.
>> but for NFS this must be something else and I did not trace
>> it completely. One of the security checks, I guess?
>> if NFS patch is changed to check inode_permission(dir, MAY_OPEN | MAY_EXEC)
>> as in Lustre, that returns 0 no matter what.
>> 
>> This is trivial to reproduce too.
> 
> So, should we be ignoring the MAY_EXEC flag when the VFS asks for inode_permission(dir, MAY_WRITE|MAY_EXEC)? I suspect that is the problem here.

You know, I have been wrong here.
VFS is not in the way.
it's the NFS server that's returning us the error:
[  326.069066] NFS: mkdir(0:44/12), test
[  326.070510] nfsd_dispatch: vers 3 proc 9
[  326.071612] nfsd: MKDIR(3)    16: 01010001 00000000 0000000c 4b3b7a92 00000000 00000000 test
[  326.071617] nfsd: fh_verify(16: 01010001 00000000 0000000c 4b3b7a92 00000000 00000000)
[  326.071684] fh_verify: /racer permission failure, acc=3, error=13

So I guess nfsd wants to be lazy too?
What side do you think this is best fixed then? the client or the server?
Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:40632 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751150AbcGGQ71 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jul 2016 12:59:27 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Oleg Drokin <green@linuxhacker.ru>
CC: Trond Myklebust <trondmy@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Viro Alexander <viro@ZenIV.linux.org.uk>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs: Fix spurios EPERM when mkdir of existing dentry
Date: Thu, 7 Jul 2016 16:59:16 +0000
Message-ID: <0438AC35-50AD-4D9E-9C23-7EED70EF2B4C@primarydata.com>
References: <1467870827-2959489-1-git-send-email-green@linuxhacker.ru>
 <1467870827-2959489-2-git-send-email-green@linuxhacker.ru>
 <9F6E5530-CBA4-4A0A-BAE1-72AAC28DB4D1@primarydata.com>
 <F3D54183-12C6-458F-B4DB-05016EAA6272@linuxhacker.ru>
In-Reply-To: <F3D54183-12C6-458F-B4DB-05016EAA6272@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 7, 2016, at 12:52, Oleg Drokin <green@linuxhacker.ru> wrote:
> 
> 
> On Jul 7, 2016, at 12:16 PM, Trond Myklebust wrote:
> 
>> 
>>> On Jul 7, 2016, at 01:53, Oleg Drokin <green@linuxhacker.ru> wrote:
>>> 
>>> It's great when we can shave an extra RPC, but not at the expense
>>> of correctness.
>>> We should not return EPERM (from vfs_create/mknod/mkdir) if the
>>> name already exists, even if we have no write access in parent.
>>> 
>>> Since the check in nfs_permission is clearly not enough to stave
>>> off this, just throw in the extra READ access to actually
>>> go through.
>>> 
>>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>>> ---
>>> fs/nfs/dir.c | 4 +++-
>>> 1 file changed, 3 insertions(+), 1 deletion(-)
>>> 
>>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>>> index d8015a0..8c7835b 100644
>>> --- a/fs/nfs/dir.c
>>> +++ b/fs/nfs/dir.c
>>> @@ -1383,8 +1383,10 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
>>> 	/*
>>> 	 * If we're doing an exclusive create, optimize away the lookup
>>> 	 * but don't hash the dentry.
>>> +	 * This optimization only works if we can write in the parent.
>>> 	 */
>>> -	if (nfs_is_exclusive_create(dir, flags))
>>> +	if (nfs_is_exclusive_create(dir, flags) &&
>>> +	    (inode_permission(dir, MAY_WRITE | MAY_READ | MAY_EXEC) == 0))
>>> 		return NULL;
>>> 
>> 
>> NACK. The only write permission we should care about on the client side is whether or not the filesystem is mounted read-only. All other permissions are checked by the server.
> 
> Right. This was mostly a discussion piece.
> The problem here is nfs_permission() returns 0 if you check for
> inode_permission(dir, MAY_WRITE | MAY_EXEC) (as in may_create), but then
> some other checks in the kernel still catch on to the fact that the directory
> is not writeable, so we have a premature failure with EPERM and server never sees
> this request which breaks things.

Are these VFS level checks? Which ones?

> 
> (the read-only mount is not handled as well at the moment of course and my patch
> does not address this issue either, but it's easier to address in the VFS, like
> in filename_create() or something).
> 
> I see that two major consumers of this nfs_permission MAY_WRITE|!MAY_READ check
> are creates and deletes and with deletes we had a lookup already, so it already
> looked up the child and revalidated the parent.
> For creates, a revalidation still might be needed, I guess and that was the main driver
> behind this check? And that only when you do current dir creates, because otherwise
> the parent would have been revalidated in lookup?
> Is this the major case why that check is actually there?
> 
> Just trying to see how to approach this better without breaking the applications.


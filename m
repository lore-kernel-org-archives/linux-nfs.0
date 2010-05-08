Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:25734 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231Ab0EHRGy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 May 2010 13:06:54 -0400
Message-ID: <4BE56180.2020307@oracle.com>
Date: Sat, 08 May 2010 09:05:04 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Neil Brown <neilb@suse.de>
CC: Trond Myklebust <trond.myklebust@fys.uio.no>, linux-nfs@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH] Should we expect close-to-open consistency on directories?
References: <20100420172238.520eaa89@notabene.brown>	<1271768521.25129.94.camel@localhost.localdomain>	<20100421170321.41592c77@notabene.brown>	<20100506141347.06451f56@notabene.brown>	<1273154311.7699.33.camel@localhost.localdomain> <20100508083415.54231ffe@notabene.brown>
In-Reply-To: <20100508083415.54231ffe@notabene.brown>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/07/2010 06:34 PM, Neil Brown wrote:
> On Thu, 06 May 2010 09:58:31 -0400 Trond Myklebust<trond.myklebust@fys.uio.no>  wrote:
>>>
>>>
>>> diff --git a/fs/namei.c b/fs/namei.c
>>> index a7dce91..256ae13 100644
>>> --- a/fs/namei.c
>>> +++ b/fs/namei.c
>>> @@ -719,7 +719,11 @@ static int do_lookup(struct nameidata *nd, struct qstr *name,
>>>   done:
>>>   	path->mnt = mnt;
>>>   	path->dentry = dentry;
>>> -	__follow_mount(path);
>>> +	if (__follow_mount(path)&&
>>> +	    (path->mnt->mnt_sb->s_type->fs_flags&  FS_REVAL_DOT)) {
>>> +		if (!path->dentry->d_op->d_revalidate(path->dentry, nd))
>>> +			return -ESTALE;
>>
>> Won't this prevent you from ever being able to unmount the stale
>> filesystem?
>>
>
> Good point - I think you are right.
>
> It seems to me that ->d_revalidate is being used for two distinct, though
> related, tasks.
> One is to revalidate the dentry - make sure the name still refers to the same
> inode.  The other is to revalidate the inode - make sure the cached
> attributes are still valid.  In NFS (v3 and v4 at least) these are both
> performed by one call so it makes some sense to combine them.  But from the
> VFS perspective I would have thought they were quite separate.
> nfs_lookup_revalidate sometimes does a GETATTR, and sometimes does a LOOKUP,
> depending to some extent on the 'intent' in the nameidata.  I find this makes
> it a bit hard to follow what is really happening, or how d_revalidate should
> really be used.
>
> Maybe we should just ignore the return value above.  Or maybe d_revalidate
> should never do a GETATTR - that should be done by ->open ??
>
> Confused :-(

The reason for this arrangement is that by the time ->open is called, 
it's too late to return ESTALE.  During the path walk, there is still an 
opportunity to renew the mapping between dentry and inode, should the 
cached value of that mapping be stale.

-- 
chuck[dot]lever[at]oracle[dot]com

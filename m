Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.bluemeaney.com ([205.234.16.187]:56771 "EHLO
	relay03.bluemeaney.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899Ab1CWJmX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 05:42:23 -0400
Message-ID: <4D89BCE6.3040707@nexenta.com>
Date: Wed, 23 Mar 2011 12:27:02 +0300
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] nfs4: Fix NULL dereference at d_alloc_and_lookup()
References: <1300830025-17152-1-git-send-email-gusev.vitaliy@nexenta.com>	 <1300830742.9442.53.camel@lade.trondhjem.org>	 <1300834707.17103.61.camel@vT510> <1300838379.22796.35.camel@lade.trondhjem.org>
In-Reply-To: <1300838379.22796.35.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/23/2011 02:59 AM, Trond Myklebust wrote:
> On Wed, 2011-03-23 at 01:58 +0300, Vitaliy Gusev wrote:
>> On Tue, 2011-03-22 at 17:52 -0400, Trond Myklebust wrote:
>>> On Wed, 2011-03-23 at 00:40 +0300, Vitaliy Gusev wrote:
>>>> From: Gusev Vitaliy<gusev.vitaliy@nexenta.com>
>>>>
>>>> d_alloc_and_lookup() calls i_op->lookup method due to
>>>> rootfh changes his fsid.
>>>>
>>>> During mount i_op of NFS root inode is set to
>>>> nfs_mountpoint_inode_operations, if rpc_ops->getroot()
>>>> and rpc_ops->getattr() return different fsid.
>>>
>>> That is a server bug! Why are you trying to "fix" that on the client
>>> instead of telling the user that their server deserves to be burned
>>> behind the shed?
>>>
>>
>> Because nfs_update_inode() does it with success and pleasure:
>>
>> 	if (S_ISDIR(inode->i_mode)&&  (fattr->valid&  NFS_ATTR_FATTR_FSID)&&
>> 			!nfs_fsid_equal(&server->fsid,&fattr->fsid)&&
>> 			!IS_AUTOMOUNT(inode))
>> 		server->fsid = fattr->fsid;
>>
>> And what are the reasons to tell to user about broken servers during
>> mount, but do not tell about it after mount ?
>
> Sigh... That is a valid point.
>
> Looking at the Linux NFS server, I see that it has 3 different ways to
> derive a fsid: only two are guaranteed to survive a reboot. I believe
> that is probably why we added the above code to nfs_update_inode().
>
> Looking now at the uses of nfs4_get_root(), it looks as if all the users
> have compared the original fsid to the super block fsid prior to getting
> here, and so we know (hope) that the directory that was obtained with
> this filehandle did at one point match. If that is always the case, then
> we should be safe w.r.t. mistaking this for a server-side mountpoint.
> Since a referral is supposed to give us an error when we try to get the
> directory attributes,

Check on referral at nfs4_get_rootfh():

	if (fsinfo.fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) {
		printk(KERN_ERR "nfs4_get_rootfh:"
		       " getroot obtained referral\n");
		ret = -EREMOTE;
		goto out;
	}

is vain and can be removed. That path never sets NFS_ATTR_FATTR_V4_REFERRAL.

then we know this isn't pointing to a referral.


Check

(A)
	if (mntroot->d_inode->i_op != 
NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
		dput(mntroot);
		error = -ESTALE;
		goto error_splat_super;
	}

was initially added by commit 4c1fe2f7 and now is not required because:

   1. This patch fixes of changing i_op at nfs_fhget(). So 
nfs4_get_root() always will return i_op == dir_inode_ops.

   2. commit 4c1fe2f7 fixed BUG_ON at nfs_follow_mountpoint(). Now there 
is no BUG_ON. It was replaced with ESTALE by commit 44d5759d

So only one thing that does check (A) -  it fixes changing fsid 
behaviour for NFSv2,NFSv3 protocol - nfs_xdev_mount(). In other places 
it can be removed:

*** fs/nfs/super.c:
nfs_xdev_mount[2483]           if (mntroot->d_inode->i_op != 
NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {

nfs4_xdev_mount[3066]          if (mntroot->d_inode->i_op != 
NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {

nfs4_remote_referral_mount[3153] if (mntroot->d_inode->i_op != 
NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {



>
> OK, I'll take this patch...


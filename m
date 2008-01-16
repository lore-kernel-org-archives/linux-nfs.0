From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] nfs-utils: Add nonegde mount option
Date: Wed, 16 Jan 2008 15:45:57 -0500
Message-ID: <52702636-6CAA-4766-B3EF-264ECA404B59@oracle.com>
References: <20080115163130.GD18911@newbie.thebellsplace.net> <243A7D1D-E2DB-4669-8E19-6D07D03144FF@oracle.com> <20080116011305.GA26010@newbie.thebellsplace.net>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:42898 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbYAPUrg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2008 15:47:36 -0500
In-Reply-To: <20080116011305.GA26010-y89O8yXFYpDSsb2jM9SCN5/hYUUxywnI@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Bob -

On Jan 15, 2008, at 8:13 PM, Bob Bell wrote:
> On Tue, Jan 15, 2008 at 11:42:54AM -0500, Chuck Lever wrote:
>> On Jan 15, 2008, at 11:31 AM, Bob Bell wrote:
>>> diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
>>> index 7df8fb2..2deca87 100644
>>> --- a/utils/mount/nfs_mount.h
>>> +++ b/utils/mount/nfs_mount.h
>>> @@ -50,21 +50,22 @@ struct nfs_mount_data {
>>> /* bits in the flags field */
>>> -#define NFS_MOUNT_SOFT		0x0001	/* 1 */
>>> -#define NFS_MOUNT_INTR		0x0002	/* 1 */
>>> -#define NFS_MOUNT_SECURE	0x0004	/* 1 */
>>> -#define NFS_MOUNT_POSIX		0x0008	/* 1 */
>>> -#define NFS_MOUNT_NOCTO		0x0010	/* 1 */
>>> -#define NFS_MOUNT_NOAC		0x0020	/* 1 */
>>> -#define NFS_MOUNT_TCP		0x0040	/* 2 */
>>> -#define NFS_MOUNT_VER3		0x0080	/* 3 */
>>> -#define NFS_MOUNT_KERBEROS	0x0100	/* 3 */
>>> -#define NFS_MOUNT_NONLM		0x0200	/* 3 */
>>> -#define NFS_MOUNT_BROKEN_SUID	0x0400	/* 4 */
>>> -#define NFS_MOUNT_NOACL     0x0800  /* 4 */
>>> -#define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 */
>>> -#define NFS_MOUNT_NORDIRPLUS	0x4000	/* 5 */
>>> -#define NFS_MOUNT_UNSHARED	0x8000	/* 5 */
>>> +#define NFS_MOUNT_SOFT		0x00001	/* 1 */
>>> +#define NFS_MOUNT_INTR		0x00002	/* 1 */
>>> +#define NFS_MOUNT_SECURE	0x00004	/* 1 */
>>> +#define NFS_MOUNT_POSIX		0x00008	/* 1 */
>>> +#define NFS_MOUNT_NOCTO		0x00010	/* 1 */
>>> +#define NFS_MOUNT_NOAC		0x00020	/* 1 */
>>> +#define NFS_MOUNT_TCP		0x00040	/* 2 */
>>> +#define NFS_MOUNT_VER3		0x00080	/* 3 */
>>> +#define NFS_MOUNT_KERBEROS	0x00100	/* 3 */
>>> +#define NFS_MOUNT_NONLM		0x00200	/* 3 */
>>> +#define NFS_MOUNT_BROKEN_SUID	0x00400	/* 4 */
>>> +#define NFS_MOUNT_NOACL		0x00800	/* 4 */
>>> +#define NFS_MOUNT_SECFLAVOUR	0x02000	/* 5 */
>>> +#define NFS_MOUNT_NORDIRPLUS	0x04000	/* 5 */
>>> +#define NFS_MOUNT_UNSHARED	0x08000	/* 5 */
>>> +#define NFS_MOUNT_NONEGDE	0x10000	/* 5 */
>>
>> Why is the patch replacing all the flag definitions?  Did you  
>> check  for inadvertent white space damage?
>
> Actually, I fixed one bit of erroneous whitespace I found (spaces  
> instead of tab).  The reason the definitions all change is because  
> a leading 0.  The existing flags were 0x0001 through 0x8000.  The  
> new flag is 0x10000.  I thought would be nice to make the flags all  
> 5 digits so that they visually lined up.

<EYEBALL CHECK> OK, I see it now.

> I don't have to do that; it does make the patch uglier, but IMHO I  
> think the resulting file is nicer.

Why not just expand these to 8 hex digits, and be done with it?

>> As I understand it, we aren't adding new options to the legacy  
>> part  of the nfs-utils mount command any longer.  Instead, add  
>> support for  the option in the kernel's NFS mount option parser in  
>> fs/nfs/super.c.
>
> Oh, perhaps I didn't fully investigate the context.  I was just  
> following the pattern I saw.  I can see if it still works without  
> that one snippet (I believe I already updated fs/nfs/super.c  
> appropriately).  I presume updating the man page is still  
> appropriate though, correct?

Yes; as long as you have the very latest version.  See Steve's nfs- 
utils git repo (I think git://linux-nfs.org/nfs-utils is the correct  
one).

> What about defining the flag?  If it's not going to be used, should  
> it still be defined as a placeholder?  I'll default to "yes" unless  
> I hear otherwise.


In the name of having utils/mount/nfs_mount.h match what's in include/ 
linux/nfs_mount.h, I guess it is reasonable to define the flag in  
both places.  IMO it would be nicer if nfs-utils just used the kernel  
header instead.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

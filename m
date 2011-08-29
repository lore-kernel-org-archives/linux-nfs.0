Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:48951 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075Ab1H2Phd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 11:37:33 -0400
Subject: Re: [PATCH] NFS: Add "device" tag to /proc/self/mountstats
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E5BA855.2030109@netapp.com>
Date: Mon, 29 Aug 2011 11:36:50 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Message-Id: <EED25A6A-29FA-4717-AA1B-2E7AE6C89D22@oracle.com>
References: <4E5807A8.2020600@netapp.com> <6701215B-7718-4EE2-9EC4-BFE0936B0D2A@oracle.com> <4E5B981A.1020605@netapp.com> <7F5CA899-5277-4F74-A10F-8F889347F445@oracle.com> <4E5BA855.2030109@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 29, 2011, at 10:55 AM, Bryan Schumaker wrote:

> On 08/29/2011 10:43 AM, Chuck Lever wrote:
>> 
>> On Aug 29, 2011, at 9:46 AM, Bryan Schumaker wrote:
>> 
>>> On 08/27/2011 07:52 PM, Chuck Lever wrote:
>>>> 
>>>> On Aug 26, 2011, at 4:52 PM, Bryan Schumaker wrote:
>>>> 
>>>>> nfsiostat was failing to find mounted filesystems on recent kernels due
>>>>> to changes in the VFS that resulted in a missing "device" tag in the
>>>>> /proc/self/mountstats file.
>>>> 
>>>> What was the commit ID that changed this formal kernel API?  I'd like to see the justification.
>>> 
>>> It was changed by this commit:
>>> 
>>> commit c7f404b40a3665d9f4e9a927cc5c1ee0479ed8f9
>>> Author: Al Viro <viro@zeniv.linux.org.uk>
>>> Date:   Wed Mar 16 06:59:40 2011 -0400
>>> 
>>>   vfs: new superblock methods to override /proc/*/mount{s,info}
>>> 
>>>   a) ->show_devname(m, mnt) - what to put into devname columns in mounts,
>>>   mountinfo and mountstats
>>>   b) ->show_path(m, mnt) - what to put into relative path column in mountinfo
>>> 
>>>   Leaving those NULL gives old behaviour.  NFS switched to using those.
>>> 
>>>   Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
>> 
>> It looks like dropping the "device" tag from /proc/self/mountstats was not intentional, so this is a kernel API regression.  At a guess, 2.6.39 probably works right, but 3.0 is broken.  Whatever solution we come up with might need to be cc:d to stable@kernel.org.  Be sure to verify which released kernels are broken.
> 
> I'll double check that 39 works.
>> 
>> Does changing nfs_show_devname() to add a "device" tag have any effect on the other two /proc files (mounts and mountinfo)?  I suspect you do want to fix show_vfsstat() instead of nfs_show_devname().  This should add "device" only where it is needed, and would work for all file systems.
> 
> Yeah, looks like it changes both.  I'm looking at show_vfsstat() now, but nfs_show_devname() will return an error if a call to nfs_path() fails.  This would probably result in an empty "device " line printed to /proc/self/mountstats.  Do you know if that would be a problem for anything?

The only error return from nfs_path() is if the name is too long.  You could change nfs_show_devname() to output a fixed error string in that case (like "path too long"), or something even more generic.

> I'm thinking about doing something like this:
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 22bfe82..1429114 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1109,6 +1109,7 @@ static int show_vfsstat(struct seq_file *m, void *v)
> 
>        /* device */
>        if (mnt->mnt_sb->s_op->show_devname) {
> +               seq_puts(m, "device ");
>                err = mnt->mnt_sb->s_op->show_devname(m, mnt);
>        } else {
>                if (mnt->mnt_devname) {

There probably isn't a clean way to have just one seq_puts(m, "device "); invocation in this function.

> 
> 
>> 
>>> 
>>> 
>>>> 
>>>>> This patch re-adds the "device" tag for NFS
>>>>> mount data in /proc/self/mountstats.
>>>> 
>>>> The purpose of mountstats is to be an interface that all file systems can use.  If we can't add "device" back to all mounts listed in /proc/self/mountstats, it might be better to adjust nfsiostats to cope.
>>>> 
>>>>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>>>>> ---
>>>>> fs/nfs/super.c |    4 +++-
>>>>> 1 files changed, 3 insertions(+), 1 deletions(-)
>>>>> 
>>>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>>>> index b961cea..e6a0317 100644
>>>>> --- a/fs/nfs/super.c
>>>>> +++ b/fs/nfs/super.c
>>>>> @@ -766,8 +766,10 @@ static int nfs_show_devname(struct seq_file *m, struct vfsmount *mnt)
>>>>> 	devname = nfs_path(&dummy, mnt->mnt_root, page, PAGE_SIZE);
>>>>> 	if (IS_ERR(devname))
>>>>> 		err = PTR_ERR(devname);
>>>>> -	else
>>>>> +	else {
>>>>> +		seq_puts(m, "device ");
>>>>> 		seq_escape(m, devname, " \t\n\\");
>>>>> +	}
>>>>> 	free_page((unsigned long)page);
>>>>> 	return err;
>>>>> }
>>>>> -- 
>>>>> 1.7.6
>>>> 
>>> 
>> 
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





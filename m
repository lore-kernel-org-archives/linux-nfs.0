Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390Ab1H2NqF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Aug 2011 09:46:05 -0400
Message-ID: <4E5B981A.1020605@netapp.com>
Date: Mon, 29 Aug 2011 09:46:02 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Add "device" tag to /proc/self/mountstats
References: <4E5807A8.2020600@netapp.com> <6701215B-7718-4EE2-9EC4-BFE0936B0D2A@oracle.com>
In-Reply-To: <6701215B-7718-4EE2-9EC4-BFE0936B0D2A@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/27/2011 07:52 PM, Chuck Lever wrote:
> 
> On Aug 26, 2011, at 4:52 PM, Bryan Schumaker wrote:
> 
>> nfsiostat was failing to find mounted filesystems on recent kernels due
>> to changes in the VFS that resulted in a missing "device" tag in the
>> /proc/self/mountstats file.
> 
> What was the commit ID that changed this formal kernel API?  I'd like to see the justification.

It was changed by this commit:

commit c7f404b40a3665d9f4e9a927cc5c1ee0479ed8f9
Author: Al Viro <viro@zeniv.linux.org.uk>
Date:   Wed Mar 16 06:59:40 2011 -0400

    vfs: new superblock methods to override /proc/*/mount{s,info}
    
    a) ->show_devname(m, mnt) - what to put into devname columns in mounts,
    mountinfo and mountstats
    b) ->show_path(m, mnt) - what to put into relative path column in mountinfo
    
    Leaving those NULL gives old behaviour.  NFS switched to using those.
    
    Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>


> 
>> This patch re-adds the "device" tag for NFS
>> mount data in /proc/self/mountstats.
> 
> The purpose of mountstats is to be an interface that all file systems can use.  If we can't add "device" back to all mounts listed in /proc/self/mountstats, it might be better to adjust nfsiostats to cope.
> 
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>> fs/nfs/super.c |    4 +++-
>> 1 files changed, 3 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index b961cea..e6a0317 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -766,8 +766,10 @@ static int nfs_show_devname(struct seq_file *m, struct vfsmount *mnt)
>> 	devname = nfs_path(&dummy, mnt->mnt_root, page, PAGE_SIZE);
>> 	if (IS_ERR(devname))
>> 		err = PTR_ERR(devname);
>> -	else
>> +	else {
>> +		seq_puts(m, "device ");
>> 		seq_escape(m, devname, " \t\n\\");
>> +	}
>> 	free_page((unsigned long)page);
>> 	return err;
>> }
>> -- 
>> 1.7.6
> 


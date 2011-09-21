Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751256Ab1IUSbN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 14:31:13 -0400
Message-ID: <4E7A2D70.6000400@RedHat.com>
Date: Wed, 21 Sep 2011 14:31:12 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Bryan Schumaker <bjschuma@netapp.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] Changes in 3.1 kernel break NFS monitoring tools
References: <1316629016-27740-1-git-send-email-steved@redhat.com> <4E7A2C27.8020209@netapp.com>
In-Reply-To: <4E7A2C27.8020209@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/21/2011 02:25 PM, Bryan Schumaker wrote:
> On 09/21/2011 02:16 PM, Steve Dickson wrote:
>> Both parser of nfsiostat and mountstats depend on the 
>> the first word in /proc/self/mountstats to be 'device'
>> for them to parse through all the devices. 
>>
>> NFS mounts entries,  in 3.1,  no longer have start with
>> the word 'device'. They start with the actual device, 
>> which confused both set of parsing routines.
> 
> I sent in a patch to fix this on the kernel end almost a month ago, but it must have gotten lost with the kernel.org confusion.  I included what I came up with below
Interesting... Maybe we should still apply these patches until
your patch shows up? They are definitely broken... 

steved.
.
> 
> - Bryan
> 
> [PATCH] VFS: Add "device" tag to /proc/self/mountstats
> 
> nfsiostat was failing to find mounted filesystems on kernels after
> 2.6.38 because of changes to show_vfsstat() by commit
> c7f404b40a3665d9f4e9a927cc5c1ee0479ed8f9.  This patch adds back the
> "device" tag before the nfs server entry so scripts can parse the
> mountstats file correctly.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/namespace.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 22bfe82..1429114 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1109,6 +1109,7 @@ static int show_vfsstat(struct seq_file *m, void *v)
>  
>  	/* device */
>  	if (mnt->mnt_sb->s_op->show_devname) {
> +		seq_puts(m, "device ");
>  		err = mnt->mnt_sb->s_op->show_devname(m, mnt);
>  	} else {
>  		if (mnt->mnt_devname) {
> 
> 
>>
>> Steve Dickson (2):
>>   nfsiostat: Breaks on 3.1 kernels
>>   mountstats: Breaks on 3.1 kernels
>>
>>  tools/mountstats/mountstats.py |    9 +++++++++
>>  tools/nfs-iostat/nfs-iostat.py |   11 +++++++++--
>>  2 files changed, 18 insertions(+), 2 deletions(-)
>>
> 

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:34683 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753480Ab0ITJ1H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 05:27:07 -0400
Message-ID: <4C9728E4.9070205@suse.de>
Date: Mon, 20 Sep 2010 14:57:00 +0530
From: Suresh Jayaraman <sjayaraman@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Neil Brown <neilb@suse.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: introduce mount option '-olocal_lock' to make locks
 local
References: <4C91B5B5.2040603@suse.de> <1284761749.16553.18.camel@heimdal.trondhjem.org>
In-Reply-To: <1284761749.16553.18.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/18/2010 03:45 AM, Trond Myklebust wrote:
> On Thu, 2010-09-16 at 11:44 +0530, Suresh Jayaraman wrote:
>> Hi Trond,
>>
>> I'm resending this patch as a separate email as I have not heard from you.
>>
>> Changes since last post:
>>   - remove unneeded NFS_MOUNT_NONLM flag checks from do_getlk()/do_setlk()/do_unlck
>>   - update comments to include the new mount option
>>
> 
> Hi Suresh,
> 
> Just a couple of comments:
> 
>       * Firstly the legacy binary mount interface uses
>         NFS_MOUNT_NONLM=0x200, so we cannot change that value. What I
>         was suggesting was rather that we just parse it to mean
>         NFS_MOUNT_LOCAL_FLOCK | NFS_MOUNT_LOCAL_FCNTL.

Ah, ok. Will fix it in the next spin.

>       * Have you tested this with NFSv4? I think I asked you this
>         previously, but I haven't seen an answer. I ask because -onolock
>         used to cause NFSv4 reboot recovery to Oops since the struct
>         file_lock didn't have any associated nfsv4 lock state. I just
>         want to make sure we're not re-enabling that bug.
> 

I had earlier tested the patch with NFSv4 but I didn't test the reboot
recovery. And, you guessed it right - with "-olocal_lock=all", the patch
causes an oops in _nfs4_do_setlk() when the server recovers after a
reboot. Clearing the new flags in nfs4_validate_mount_flags() fixes the
problem. Also, I have updated the patch to take into account the nfsroot
case.

I also noticed Chuck's recent patchset will move nfsroot option
handling. I'll rebase by patch against nfs-2.6.git and resend it.

Thanks,

-- 
Suresh Jayaraman

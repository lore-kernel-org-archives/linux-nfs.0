Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53498 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755577AbaCKW4J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2014 18:56:09 -0400
Message-ID: <531F9486.6050504@RedHat.com>
Date: Tue, 11 Mar 2014 18:56:06 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount.nfs: background mount now do directly into background
References: <1394284964-12997-1-git-send-email-steved@redhat.com> <E50361D2-FB5A-4A1D-BBE2-8DA25C09D865@primarydata.com>
In-Reply-To: <E50361D2-FB5A-4A1D-BBE2-8DA25C09D865@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/11/2014 05:13 PM, Trond Myklebust wrote:
> 
> On Mar 8, 2014, at 8:22, Steve Dickson <SteveD@redhat.com> wrote:
> 
>> Modern day kernel will no longer return all timeout
>> errors instead the process spins endlessly in the kernel.
>> This behavior will cause the foreground mount to hang, never
>> allowing the mount to go into background.
>>
>> So this patch eliminates the foreground mount cause
>> background mounts to go directly into background
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> utils/mount/stropts.c |   31 ++++++++-----------------------
>> 1 files changed, 8 insertions(+), 23 deletions(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index a642394..92a7245 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -913,28 +913,6 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>> }
>>
>> /*
>> - * Handle "background" NFS mount [first try]
>> - *
>> - * Returns a valid mount command exit code.
>> - *
>> - * EX_BG should cause the caller to fork and invoke nfsmount_child.
>> - */
>> -static int nfsmount_parent(struct nfsmount_info *mi)
>> -{
>> -	if (nfs_try_mount(mi))
>> -		return EX_SUCCESS;
>> -
>> -	/* retry background mounts when the server is not up */
>> -	if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP) {
>> -		mount_error(mi->spec, mi->node, errno);
>> -		return EX_FAIL;
>> -	}
>> -
>> -	sys_mount_errors(mi->hostname, errno, 1, 1);
>> -	return EX_BG;
>> -}
>> -
>> -/*
>>  * Handle "background" NFS mount [retry daemon]
>>  *
>>  * Returns a valid mount command exit code: EX_SUCCESS if successful,
>> @@ -982,7 +960,14 @@ static int nfsmount_child(struct nfsmount_info *mi)
>> static int nfsmount_bg(struct nfsmount_info *mi)
>> {
>> 	if (!mi->child)
>> -		return nfsmount_parent(mi);
>> +		/* 
>> +		 * Modern day kernels no longer return all 
>> +		 * timeouts errors in all cases, instead 
>> +		 * the process spins in the kernel, which 
>> +		 * will hang a foreground mount. So background
>> +		 * mounts have to go directly into background
>> +		 */
>> +		return EX_BG;
>> 	else
>> 		return nfsmount_child(mi);
>> }
> 
> Hi Steve,
> 
> Doesn’t this mean that ‘mount.nfs’ will no longer attempt to wait 
> for the mount to complete?
Yes. The foreground will no longer be tried....

> That’s why I suggested having the parent set a timer, and then 
> waiting for whichever comes first out of SIGCHLD or SIGALRM (indicating 
> either that the child mount process is done mounting 
> or that the timeout occurred).
Why wait? Kernels today no longer return on timeouts or ECONNREFUSED
so instead of have the foreground mounts hang forever why not
just let the background mounts hang, forever?

steved.

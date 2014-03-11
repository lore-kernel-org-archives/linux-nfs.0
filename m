Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:47123 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900AbaCKXEH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2014 19:04:07 -0400
Received: by mail-qa0-f44.google.com with SMTP id f11so9162713qae.3
        for <linux-nfs@vger.kernel.org>; Tue, 11 Mar 2014 16:04:06 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] mount.nfs: background mount now do directly into background
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <531F9486.6050504@RedHat.com>
Date: Tue, 11 Mar 2014 19:04:03 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <C36FB0D9-2C97-4E63-A1C6-C52DBCDABDF1@primarydata.com>
References: <1394284964-12997-1-git-send-email-steved@redhat.com> <E50361D2-FB5A-4A1D-BBE2-8DA25C09D865@primarydata.com> <531F9486.6050504@RedHat.com>
To: Dickson Steve <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 11, 2014, at 18:56, Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 03/11/2014 05:13 PM, Trond Myklebust wrote:
>> 
>> On Mar 8, 2014, at 8:22, Steve Dickson <SteveD@redhat.com> wrote:
>> 
>>> Modern day kernel will no longer return all timeout
>>> errors instead the process spins endlessly in the kernel.
>>> This behavior will cause the foreground mount to hang, never
>>> allowing the mount to go into background.
>>> 
>>> So this patch eliminates the foreground mount cause
>>> background mounts to go directly into background
>>> 
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>> utils/mount/stropts.c |   31 ++++++++-----------------------
>>> 1 files changed, 8 insertions(+), 23 deletions(-)
>>> 
>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index a642394..92a7245 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -913,28 +913,6 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>>> }
>>> 
>>> /*
>>> - * Handle "background" NFS mount [first try]
>>> - *
>>> - * Returns a valid mount command exit code.
>>> - *
>>> - * EX_BG should cause the caller to fork and invoke nfsmount_child.
>>> - */
>>> -static int nfsmount_parent(struct nfsmount_info *mi)
>>> -{
>>> -	if (nfs_try_mount(mi))
>>> -		return EX_SUCCESS;
>>> -
>>> -	/* retry background mounts when the server is not up */
>>> -	if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP) {
>>> -		mount_error(mi->spec, mi->node, errno);
>>> -		return EX_FAIL;
>>> -	}
>>> -
>>> -	sys_mount_errors(mi->hostname, errno, 1, 1);
>>> -	return EX_BG;
>>> -}
>>> -
>>> -/*
>>> * Handle "background" NFS mount [retry daemon]
>>> *
>>> * Returns a valid mount command exit code: EX_SUCCESS if successful,
>>> @@ -982,7 +960,14 @@ static int nfsmount_child(struct nfsmount_info *mi)
>>> static int nfsmount_bg(struct nfsmount_info *mi)
>>> {
>>> 	if (!mi->child)
>>> -		return nfsmount_parent(mi);
>>> +		/* 
>>> +		 * Modern day kernels no longer return all 
>>> +		 * timeouts errors in all cases, instead 
>>> +		 * the process spins in the kernel, which 
>>> +		 * will hang a foreground mount. So background
>>> +		 * mounts have to go directly into background
>>> +		 */
>>> +		return EX_BG;
>>> 	else
>>> 		return nfsmount_child(mi);
>>> }
>> 
>> Hi Steve,
>> 
>> Doesn’t this mean that ‘mount.nfs’ will no longer attempt to wait 
>> for the mount to complete?
> Yes. The foreground will no longer be tried....
> 
>> That’s why I suggested having the parent set a timer, and then 
>> waiting for whichever comes first out of SIGCHLD or SIGALRM (indicating 
>> either that the child mount process is done mounting 
>> or that the timeout occurred).
> Why wait? Kernels today no longer return on timeouts or ECONNREFUSED
> so instead of have the foreground mounts hang forever why not
> just let the background mounts hang, forever?

That’s the point; we would let the backgrounded mount.nfs hang for as long as it takes. However the foreground ‘mount.nfs’ process would exit after the user-specified timeout.
The reason for wanting to wait is so that the ‘bg’ entries in /etc/fstab are either known to be fully mounted, or timed out before we allow the ‘mount remote filesystems‘ init process to complete. If not, the bootup will be unpredictable, with nobody being able to rely on the mounts being present even in situations where an ‘fg’ mount would succeed instantly.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


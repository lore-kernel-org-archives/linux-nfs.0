Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42177 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750808Ab1JSSi4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 14:38:56 -0400
Message-ID: <4E9F1939.3030807@RedHat.com>
Date: Wed, 19 Oct 2011 14:38:49 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount.nfs: mtab corruption when RLIMIT_FSIZE causes
 a partial write
References: <1319038470-17750-1-git-send-email-steved@redhat.com> <20111019123626.7a80dfad@corrin.poochiereds.net> <4E9F047B.5000600@RedHat.com> <20111019132230.6cd85a0c@corrin.poochiereds.net> <4E9F0952.2040607@RedHat.com> <20111019173611.GC32028@fieldses.org>
In-Reply-To: <20111019173611.GC32028@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/19/2011 01:36 PM, J. Bruce Fields wrote:
> On Wed, Oct 19, 2011 at 01:30:58PM -0400, Steve Dickson wrote:
>>
>>
>> On 10/19/2011 01:22 PM, Jeff Layton wrote:
>>> On Wed, 19 Oct 2011 13:10:19 -0400
>>> Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>>>
>>>>
>>>> On 10/19/2011 12:36 PM, Jeff Layton wrote:
>>>>> On Wed, 19 Oct 2011 11:34:30 -0400
>>>>> Steve Dickson <steved@redhat.com> wrote:
>>>>>
>>>>>> This patch is a following on to commit 7a802337. Using the
>>>>>> tool in https://bugzilla.redhat.com/show_bug.cgi?id=695916
>>>>>> caused the fflush() and fclose() to fail in turn causing
>>>>>> corruption in the mtab.
>>>>>>
>>>>>> The failures were in the internals of both calls. Switch those
>>>>>> calls with the actual system calls eliminated the failures.
>>>>>>
>>>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>>>> ---
>>>>>>  support/nfs/nfs_mntent.c |    4 ++--
>>>>>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>>>>>
>>>>>> diff --git a/support/nfs/nfs_mntent.c b/support/nfs/nfs_mntent.c
>>>>>> index a2118a2..b80f270 100644
>>>>>> --- a/support/nfs/nfs_mntent.c
>>>>>> +++ b/support/nfs/nfs_mntent.c
>>>>>> @@ -117,7 +117,7 @@ void
>>>>>>  nfs_endmntent (mntFILE *mfp) {
>>>>>>  	if (mfp) {
>>>>>>  		if (mfp->mntent_fp)
>>>>>> -			fclose(mfp->mntent_fp);
>>>>>> +			close(fileno(mfp->mntent_fp));
>>>>>>  		if (mfp->mntent_file)
>>>>>>  			free(mfp->mntent_file);
>>>>>>  		free(mfp);
>>>>>> @@ -147,7 +147,7 @@ nfs_addmntent (mntFILE *mfp, struct mntent *mnt) {
>>>>>>  	free(m3);
>>>>>>  	free(m4);
>>>>>>  	if (res >= 0) {
>>>>>> -		res = fflush(mfp->mntent_fp);
>>>>>> +		res = fsync(fileno(mfp->mntent_fp));
>>>>>
>>>>> fsync doesn't imply an fflush. With this, I think you may end up
>>>>> without everything being committed to disk if part or all of it is
>>>>> still in the file stream buffer. You probably want to do an fflush()
>>>>> and then an fsync here.
>>>> The problem was with the fflush() call. The call was causing the
>>>> mount to drop core in turn causing mtab corruption. Changing that
>>>> call to a fsync() worked just fine... no corruption... every time! 
>>>>
>>>
>>> Ahh, then you have another problem here too then. Most likely it was
>>> crashing because it caught a SIGXFSZ. Writing out the mtab should not
>>> be affected by signals.
>> So calling fflush() generates a SIGXFSZ and call fsync() does not... 
> 
> fflush() must hit this because it's calling write() to write out the
> stream buffer....
> 
> But lock_mtab() should have set SIGXFSZ to be ignored; is that not
> happening?
This is the case. The following patch cause SIGXFSZ to be ignored.

diff -up ./utils/mount/fstab.c.orig ./utils/mount/fstab.c
--- ./utils/mount/fstab.c.orig	2011-10-19 13:28:57.318132000 -0400
+++ ./utils/mount/fstab.c	2011-10-19 14:02:07.715039000 -0400
@@ -387,8 +387,9 @@ lock_mtab (void) {
 		sa.sa_flags = 0;
 		sigfillset (&sa.sa_mask);
   
-		while (sigismember (&sa.sa_mask, ++sig) != -1
-		       && sig != SIGCHLD) {
+		while (sigismember (&sa.sa_mask, ++sig) != -1) {
+		    if (sig == SIGCHLD)
+				continue;
 			if (sig == SIGALRM)
 				sa.sa_handler = setlkw_timeout;
 			else

Now all this does is cause mount to ignore the fact that
the write() during the fflush() fails, which causes the 
following warning during the umount. 

[mntent]: warning: no final newline at the end of /etc/mtab
[mntent]: warning: no final newline at the end of /etc/mtab
[mntent]: warning: no final newline at the end of /etc/mtab

I can live with those warnings.... 

steved.

> 
>> I really don't see what the problem is is call simply calling fsync()
>> which clearly works?
> 
> We want to make sure the problem's really fixed.
> 
> --b.

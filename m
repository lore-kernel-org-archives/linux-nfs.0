Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:33634 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753559AbeCFPkN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2018 10:40:13 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] Removed -Werror=unused-result warnings.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180306153335.GA7099@fieldses.org>
Date: Tue, 6 Mar 2018 10:35:13 -0500
Cc: Steve Dickson <SteveD@RedHat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <577627CD-DE42-4143-A573-3BE1AE344025@oracle.com>
References: <20180305155420.104418-1-steved@redhat.com>
 <20180305215350.GC29226@fieldses.org>
 <86fae36c-2542-2c00-6993-d4f4d936c83b@RedHat.com>
 <20180306153335.GA7099@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Mar 6, 2018, at 10:33 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Mon, Mar 05, 2018 at 05:49:26PM -0500, Steve Dickson wrote:
>> 
>> 
>> On 03/05/2018 04:53 PM, J. Bruce Fields wrote:
>>> On Mon, Mar 05, 2018 at 10:54:20AM -0500, Steve Dickson wrote:
>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>> ---
>>>> support/nfs/nfs_mntent.c         | 3 ++-
>>>> utils/blkmapd/device-discovery.c | 6 ++++--
>>>> utils/mount/network.c            | 8 ++++++--
>>>> utils/nfsd/nfssvc.c              | 5 +++--
>>>> utils/statd/statd.c              | 3 ++-
>>>> 5 files changed, 17 insertions(+), 8 deletions(-)
>>>> 
>>>> diff --git a/support/nfs/nfs_mntent.c b/support/nfs/nfs_mntent.c
>>>> index a2118a2..c60988a 100644
>>>> --- a/support/nfs/nfs_mntent.c
>>>> +++ b/support/nfs/nfs_mntent.c
>>>> @@ -150,7 +150,8 @@ nfs_addmntent (mntFILE *mfp, struct mntent *mnt) {
>>>> 		res = fflush(mfp->mntent_fp);
>>>> 		if (res < 0)
>>>> 			/* Avoid leaving a corrupt mtab file */
>>>> -			ftruncate(fileno(mfp->mntent_fp), length);
>>>> +			if (ftruncate(fileno(mfp->mntent_fp), length))
>>>> +				{/* ignore return value */};
>>> 
>>> Might be worth a log warning?
>> Yes... I thought about that. But I could not think of any meaningful
>> log that would help diagnose the problem... The ftruncate() is basically 
>> cleanly up a mess.. 
>> 
>> Maybe log an error message from the fflush()? 
> 
> Yeah, and I admit maybe it's not worth anything specifically by the time
> the ftruncate also fails.

Acknowledging that fact in the comment might be a good idea.

--
Chuck Lever




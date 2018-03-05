Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51436 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752508AbeCEWt1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Mar 2018 17:49:27 -0500
Subject: Re: [PATCH] Removed -Werror=unused-result warnings.
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180305155420.104418-1-steved@redhat.com>
 <20180305215350.GC29226@fieldses.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <86fae36c-2542-2c00-6993-d4f4d936c83b@RedHat.com>
Date: Mon, 5 Mar 2018 17:49:26 -0500
MIME-Version: 1.0
In-Reply-To: <20180305215350.GC29226@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/05/2018 04:53 PM, J. Bruce Fields wrote:
> On Mon, Mar 05, 2018 at 10:54:20AM -0500, Steve Dickson wrote:
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  support/nfs/nfs_mntent.c         | 3 ++-
>>  utils/blkmapd/device-discovery.c | 6 ++++--
>>  utils/mount/network.c            | 8 ++++++--
>>  utils/nfsd/nfssvc.c              | 5 +++--
>>  utils/statd/statd.c              | 3 ++-
>>  5 files changed, 17 insertions(+), 8 deletions(-)
>>
>> diff --git a/support/nfs/nfs_mntent.c b/support/nfs/nfs_mntent.c
>> index a2118a2..c60988a 100644
>> --- a/support/nfs/nfs_mntent.c
>> +++ b/support/nfs/nfs_mntent.c
>> @@ -150,7 +150,8 @@ nfs_addmntent (mntFILE *mfp, struct mntent *mnt) {
>>  		res = fflush(mfp->mntent_fp);
>>  		if (res < 0)
>>  			/* Avoid leaving a corrupt mtab file */
>> -			ftruncate(fileno(mfp->mntent_fp), length);
>> +			if (ftruncate(fileno(mfp->mntent_fp), length))
>> +				{/* ignore return value */};
> 
> Might be worth a log warning?
Yes... I thought about that. But I could not think of any meaningful
log that would help diagnose the problem... The ftruncate() is basically 
cleanly up a mess.. 

Maybe log an error message from the fflush()? 

Thanks for the review!

steved.

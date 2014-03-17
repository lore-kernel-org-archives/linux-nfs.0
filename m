Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62067 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933171AbaCQOzr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Mar 2014 10:55:47 -0400
Message-ID: <53270CF1.30007@RedHat.com>
Date: Mon, 17 Mar 2014 10:55:45 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Don't retry server trunking discovery on timeouts
 (v2)
References: <1394207049-2447-1-git-send-email-steved@redhat.com> <53270A79.1080306@RedHat.com>
In-Reply-To: <53270A79.1080306@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/17/2014 10:45 AM, Steve Dickson wrote:
> Trond,
> 
> On 03/07/2014 10:44 AM, Steve Dickson wrote:
>> To allow background mounts to process into background,
>> server trunking discovery needs to return the -ETIMEDOUT
>> error to the mount command instead of endless retrying in
>> the kernel.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
> Any chance of reconsidering this patch? Or come up
> with a better a way for the kernel to start returning ETIMEOUTS
> and ECONNREFUSEDs again? 
At least in the mount path I should say.... 

steved.
> 
> steved.
>> ---
>>  fs/nfs/nfs4state.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index e1a4721..e0e4d34 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -2083,8 +2083,9 @@ again:
>>  	switch (status) {
>>  	case 0:
>>  		break;
>> -	case -NFS4ERR_DELAY:
>>  	case -ETIMEDOUT:
>> +		break;
>> +	case -NFS4ERR_DELAY:
>>  	case -EAGAIN:
>>  		ssleep(1);
>>  	case -NFS4ERR_STALE_CLIENTID:
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

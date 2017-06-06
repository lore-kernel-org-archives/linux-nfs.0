Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37685 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751390AbdFFVCt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Jun 2017 17:02:49 -0400
Subject: Re: [PATCH] mount.nfs: Use default minor version when -t nfs4 is
 specified
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20170606194812.4248-1-steved@redhat.com>
 <5D1A0F34-DD8D-465E-BF94-7E2C92EC8282@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <6bc13046-8098-8cce-189a-6977b86e8efc@RedHat.com>
Date: Tue, 6 Jun 2017 17:02:47 -0400
MIME-Version: 1.0
In-Reply-To: <5D1A0F34-DD8D-465E-BF94-7E2C92EC8282@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/06/2017 03:52 PM, Chuck Lever wrote:
> 
>> On Jun 6, 2017, at 3:48 PM, Steve Dickson <steved@redhat.com> wrote:
>>
>> When the nfs4 filesystem specified, the default minor
>> version should be used not v4.0.
> 
> Isn't the default specified in the mountnfs config file?
It can be... But in general its not... 

So the question is when the nfs4 file system (aka -t nfs4)
what minor version does that mean? v4.0 which was the 
default in the past or the new default v4.2?

steved.
> 
> 
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> utils/mount/stropts.c | 3 ++-
>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index c0266e5..57efb26 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -317,7 +317,8 @@ static int nfs_set_version(struct nfsmount_info *mi)
>>
>> 	if (strncmp(mi->type, "nfs4", 4) == 0) {
>> 		mi->version.major = 4;
>> -		mi->version.v_mode = V_GENERAL;
>> +		mi->version.minor = 2;
>> +		mi->version.v_mode = V_SPECIFIC;
>> 	}
>> 	/*
>> 	 * Before 2.6.32, the kernel NFS client didn't
>> -- 
>> 2.9.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 

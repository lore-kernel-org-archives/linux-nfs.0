Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43562 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500Ab2FFVBJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jun 2012 17:01:09 -0400
Message-ID: <4FCFC4E0.7020108@RedHat.com>
Date: Wed, 06 Jun 2012 17:00:16 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Map minor mismatch error to protocol not support
 error.
References: <1339006327-27815-1-git-send-email-steved@redhat.com> <63B16CAE-BAE9-471F-B213-65D990A0788B@oracle.com>
In-Reply-To: <63B16CAE-BAE9-471F-B213-65D990A0788B@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/06/2012 02:31 PM, Chuck Lever wrote:
> 
> On Jun 6, 2012, at 2:12 PM, Steve Dickson wrote:
> 
>> Sservers that only have NFSv4.1 support the
>> NFS4ERR_MINOR_VERS_MISMATCH error is return on
>> v4.0 mounts. Mapping that error to EPROTONOSUPPORT
>> will cause the mount to back off to v3 instead of
>> failing.
> 
> Should we try NFSv4.0 first?
We do try v4.0 first and that mount fails with 
NFS4ERR_MINOR_VERS_MISMATCH. Today the kenrel sends up
an  EIO error which causes the mount to fail. With this 
patch, the kernel will send up a EPROTONOSUPPORT error
which will cause a v3 mount to be tried... 

steved.

> 
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> fs/nfs/nfs4proc.c |    2 ++
>> 1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index d48dbef..eda028b 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -105,6 +105,8 @@ static int nfs4_map_errors(int err)
>> 		return -EINVAL;
>> 	case -NFS4ERR_SHARE_DENIED:
>> 		return -EACCES;
>> +	case -NFS4ERR_MINOR_VERS_MISMATCH:
>> +		return -EPROTONOSUPPORT;
>> 	default:
>> 		dprintk("%s could not handle NFSv4 error %d\n",
>> 				__func__, -err);
>> -- 
>> 1.7.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> ---
> Chuck Lever
> chuck [dot] lever [at] oracle [dot] com
> 
> 
> 
> 

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:35480 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751335AbeFVO2a (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jun 2018 10:28:30 -0400
Subject: Re: [PATCH 1/2] nfsv4: handle ENOSPC during create session
To: Trond Myklebust <trondmy@hammerspace.com>
References: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
 <fcbb5bdcf513cd8aff17e33403688cf1cecdee3d.camel@hammerspace.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Manjunath Patil <manjunath.b.patil@oracle.com>
Message-ID: <a1ef068f-57f3-6af1-4f94-7b4fc7a317ca@oracle.com>
Date: Fri, 22 Jun 2018 07:28:24 -0700
MIME-Version: 1.0
In-Reply-To: <fcbb5bdcf513cd8aff17e33403688cf1cecdee3d.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thank you for your comments Trond. Let me come back with better version.

-Thanks,
Manjunath
On 6/21/2018 10:04 AM, Trond Myklebust wrote:
> On Thu, 2018-06-21 at 16:35 +0000, Manjunath Patil wrote:
>> Presently the client mount hangs for NFS4ERR_NOSPC repsonse from
>> server
>> during create session operation. Handle this error at the client side
>> and pass it back to user-space, which may chose to mount with lower
>> nfs
>> versions.
>>
>> Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
>> ---
>>   fs/nfs/nfs4state.c | 6 ++++++
>>   1 file changed, 6 insertions(+)
>>
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 2bf2eaa..2134cf5 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -381,6 +381,8 @@ int nfs41_discover_server_trunking(struct
>> nfs_client *clp,
>>   	}
>>   	nfs4_schedule_state_manager(clp);
>>   	status = nfs_wait_client_init_complete(clp);
>> +	if (!status) /* -ERESTARTSYS */
>> +		status = nfs_client_init_status(clp);
> Nack... The trunking code is _not_ the place to do session error
> detection.
>
>>   	if (status < 0)
>>   		nfs_put_client(clp);
>>   	return status;
>> @@ -1919,6 +1921,9 @@ static int
>> nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
>>   		dprintk("%s: exit with error %d for server %s\n",
>>   				__func__, -EPROTONOSUPPORT, clp-
>>> cl_hostname);
>>   		return -EPROTONOSUPPORT;
>> +	case -NFS4ERR_NOSPC:
>> +		nfs_mark_client_ready(clp, status);
>> +		/*fall through*/
> Nack... This would cause existing mounts to suddenly permanently fail.
>
>>   	case -NFS4ERR_NOT_SAME: /* FixMe: implement recovery
>>   				 * in nfs4_exchange_id */
>>   	default:
>> @@ -2186,6 +2191,7 @@ int nfs4_discover_server_trunking(struct
>> nfs_client *clp,
>>   	case 0:
>>   	case -EINTR:
>>   	case -ERESTARTSYS:
>> +	case -NFS4ERR_NOSPC:
>>   		break;
>>   	case -ETIMEDOUT:
>>   		if (clnt->cl_softrtry)


From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 17/19] NFSD: Stricter buffer size checking in fs/nfsd/nfsctl.c
Date: Tue, 28 Apr 2009 12:36:38 -0400
Message-ID: <933CF5D0-337D-46CF-81E8-13F617BF0B2F@oracle.com>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net> <20090423233325.17283.71127.stgit@ingres.1015granger.net> <20090428163130.GL17891@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:45620 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173AbZD1Qgt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 12:36:49 -0400
In-Reply-To: <20090428163130.GL17891@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 28, 2009, at 12:31 PM, J. Bruce Fields wrote:
> On Thu, Apr 23, 2009 at 07:33:25PM -0400, Chuck Lever wrote:
>> Clean up: For consistency, handle output buffer size checking in a
>> other nfsctl functions the same way it's done for write_versions().
>
> These all look fine to me, thanks.  Let me know when you want them
> applied.

Just to confirm that 1/19 looks OK to you too... I think you can apply  
1 - 17 now.

> --b.
>
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/nfsd/nfsctl.c |   14 +++++++++-----
>> 1 files changed, 9 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>> index a152694..877e713 100644
>> --- a/fs/nfsd/nfsctl.c
>> +++ b/fs/nfsd/nfsctl.c
>> @@ -695,8 +695,9 @@ static ssize_t write_threads(struct file *file,  
>> char *buf, size_t size)
>> 		if (rv)
>> 			return rv;
>> 	}
>> -	sprintf(buf, "%d\n", nfsd_nrthreads());
>> -	return strlen(buf);
>> +
>> +	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
>> +							nfsd_nrthreads());
>> }
>>
>> /**
>> @@ -1197,7 +1198,9 @@ static ssize_t write_maxblksize(struct file  
>> *file, char *buf, size_t size)
>> 		nfsd_max_blksize = bsize;
>> 		mutex_unlock(&nfsd_mutex);
>> 	}
>> -	return sprintf(buf, "%d\n", nfsd_max_blksize);
>> +
>> +	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
>> +							nfsd_max_blksize);
>> }
>>
>> #ifdef CONFIG_NFSD_V4
>> @@ -1221,8 +1224,9 @@ static ssize_t __write_leasetime(struct file  
>> *file, char *buf, size_t size)
>> 			return -EINVAL;
>> 		nfs4_reset_lease(lease);
>> 	}
>> -	sprintf(buf, "%ld\n", nfs4_lease_time());
>> -	return strlen(buf);
>> +
>> +	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%ld\n",
>> +							nfs4_lease_time());
>> }
>>
>> /**
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





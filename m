From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 3/3] SQUASHME: spnfs: fixup LAYOUT_NFSV4_1_FILES
Date: Tue, 25 May 2010 17:44:05 +0300
Message-ID: <4BFBE235.3050500@panasas.com>
References: <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com> <1274767019-19587-1-git-send-email-bhalevy@panasas.com> <4BFBB284.1070703@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:57126 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756443Ab0EYOmb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 10:42:31 -0400
Received: by fg-out-1718.google.com with SMTP id e12so357796fga.1
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 07:42:27 -0700 (PDT)
In-Reply-To: <4BFBB284.1070703@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:
> On 05/25/2010 08:56 AM, Benny Halevy wrote:
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/spnfs_ops.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfsd/spnfs_ops.c b/fs/nfsd/spnfs_ops.c
>> index 230fb59..b97a5af 100644
>> --- a/fs/nfsd/spnfs_ops.c
>> +++ b/fs/nfsd/spnfs_ops.c
>> @@ -57,7 +57,7 @@ extern struct spnfs *global_spnfs;
>>  int
>>  spnfs_layout_type(struct super_block *sb)
>>  {
>> -	return LAYOUT_NFSV4_FILES;
>> +	return LAYOUT_NFSV4_1_FILES;
>>  }
>>  
>>  enum nfsstat4
>> @@ -218,7 +218,7 @@ spnfs_layoutrecall(struct inode *inode, int type, u64 offset, u64 len)
>>  	}
>>  
>>  	lr.cbl_recall_type = type;
>> -	lr.cbl_seg.layout_type = LAYOUT_NFSV4_FILES;
>> +	lr.cbl_seg.layout_type = LAYOUT_NFSV4_1_FILES;
>>  	lr.cbl_seg.clientid = 0;
>>  	lr.cbl_seg.offset = offset;
>>  	lr.cbl_seg.length = len;
> 
> Sorry to bother you guys but I don't like the "_" between the 4 and the 1
> I would mutch prefer the LAYOUT_NFSV41_FILES format. An "_" is an heavy wait
> that should not be used lightly.
> 

First, that's the de-facto convention we used so far.
Second, this is so unimportant I don't want to spend a second more
thinking about it... :)

Benny

> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


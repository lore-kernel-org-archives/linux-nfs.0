Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:27094 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156AbbJMTpe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2015 15:45:34 -0400
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
To: Neil Brown <nfbrown@novell.com>, <linux-nfs@vger.kernel.org>,
        <linux-btrfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-api@vger.kernel.org>, <zab@zabbo.net>,
        <viro@zeniv.linux.org.uk>, <clm@fb.com>, <darrick.wong@oracle.com>,
        <mtk.manpages@gmail.com>, <andros@netapp.com>, <hch@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <87vbai6sud.fsf@notabene.neil.brown.name>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <561D5F58.8030105@Netapp.com>
Date: Tue, 13 Oct 2015 15:45:28 -0400
MIME-Version: 1.0
In-Reply-To: <87vbai6sud.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/07/2015 09:40 PM, Neil Brown wrote:
> Anna Schumaker <Anna.Schumaker@netapp.com> writes:
> 
>> @@ -1338,34 +1362,26 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>>  			    struct file *file_out, loff_t pos_out,
>>  			    size_t len, unsigned int flags)
>>  {
>> -	struct inode *inode_in;
>> -	struct inode *inode_out;
>>  	ssize_t ret;
>>  
>> -	if (flags)
>> +	/* Flags should only be used exclusively. */
>> +	if ((flags & COPY_FR_COPY) && (flags & ~COPY_FR_COPY))
>> +		return -EINVAL;
>> +	if ((flags & COPY_FR_REFLINK) && (flags & ~COPY_FR_REFLINK))
>> +		return -EINVAL;
>> +	if ((flags & COPY_FR_DEDUP) && (flags & ~COPY_FR_DEDUP))
>>  		return -EINVAL;
>>  
> 
> Do you also need:
> 
>    if (flags & ~(COPY_FR_COPY | COPY_FR_REFLINK | COPY_FR_DEDUP))
>    	return -EINVAL;
> 
> so that future user-space can test if the kernel supports new flags?

Probably.  I'll add that in!

Thanks,
Anna

> 
> NeilBrown
> 


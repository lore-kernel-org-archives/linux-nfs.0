Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.vodafone.ie ([213.233.128.43]:57903 "EHLO
	mail1.vodafone.ie" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757124AbbJILP6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2015 07:15:58 -0400
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
To: Neil Brown <nfbrown@novell.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com, hch@infradead.org
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <87vbai6sud.fsf@notabene.neil.brown.name>
From: =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigBrady.com>
Message-ID: <5617A1E9.1080509@draigBrady.com>
Date: Fri, 9 Oct 2015 12:15:53 +0100
MIME-Version: 1.0
In-Reply-To: <87vbai6sud.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/10/15 02:40, Neil Brown wrote:
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

Seems like a good idea, yes.

Also that got me thinking about COPY_FR_SPARSE.
What's the current behavior when copying a sparse range?
Is the hole propagated by default (good), or is it expanded?

Note cp(1) has --sparse={never,auto,always}. Auto is the default,
so it would be good I think if that was the default mode for copy_file_range().
With other sparse modes, we'd have to avoid copy_file_range() unless
there was control possible with COPY_FR_SPARSE_{AUTO,NONE,ALWAYS}.
Note currently cp --sparse=always will detect runs of zeros and also
avoid speculative preallocation by using fallocate (fd, FALLOC_FL_PUNCH_HOLE, ...)

thanks,
Pádraig.

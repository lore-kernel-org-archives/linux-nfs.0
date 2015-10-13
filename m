Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:47801 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156AbbJMUZe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2015 16:25:34 -0400
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
To: =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigBrady.com>,
        Neil Brown <nfbrown@novell.com>, <linux-nfs@vger.kernel.org>,
        <linux-btrfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-api@vger.kernel.org>, <zab@zabbo.net>,
        <viro@zeniv.linux.org.uk>, <clm@fb.com>, <darrick.wong@oracle.com>,
        <mtk.manpages@gmail.com>, <andros@netapp.com>, <hch@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <87vbai6sud.fsf@notabene.neil.brown.name> <5617A1E9.1080509@draigBrady.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <561D68B9.8030209@Netapp.com>
Date: Tue, 13 Oct 2015 16:25:29 -0400
MIME-Version: 1.0
In-Reply-To: <5617A1E9.1080509@draigBrady.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/09/2015 07:15 AM, Pádraig Brady wrote:
> On 08/10/15 02:40, Neil Brown wrote:
>> Anna Schumaker <Anna.Schumaker@netapp.com> writes:
>>
>>> @@ -1338,34 +1362,26 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>>>  			    struct file *file_out, loff_t pos_out,
>>>  			    size_t len, unsigned int flags)
>>>  {
>>> -	struct inode *inode_in;
>>> -	struct inode *inode_out;
>>>  	ssize_t ret;
>>>  
>>> -	if (flags)
>>> +	/* Flags should only be used exclusively. */
>>> +	if ((flags & COPY_FR_COPY) && (flags & ~COPY_FR_COPY))
>>> +		return -EINVAL;
>>> +	if ((flags & COPY_FR_REFLINK) && (flags & ~COPY_FR_REFLINK))
>>> +		return -EINVAL;
>>> +	if ((flags & COPY_FR_DEDUP) && (flags & ~COPY_FR_DEDUP))
>>>  		return -EINVAL;
>>>  
>>
>> Do you also need:
>>
>>    if (flags & ~(COPY_FR_COPY | COPY_FR_REFLINK | COPY_FR_DEDUP))
>>    	return -EINVAL;
>>
>> so that future user-space can test if the kernel supports new flags?
> 
> Seems like a good idea, yes.
> 
> Also that got me thinking about COPY_FR_SPARSE.
> What's the current behavior when copying a sparse range?
> Is the hole propagated by default (good), or is it expanded?

I haven't tried it, but I think the hole would be expanded :(.  I'm having splice() handle the pagecache copy part, and (as far as I know) splice() doesn't know anything about sparse files.  I might be able to put in some kind of fallocate() / splice() loop to copy the range in multiple pieces.

I don't want to add COPY_FR_SPARSE_AUTO, because then the kernel will have to determine how best to interpret "auto".  I'm more inclined to add a single COPY_FR_SPARSE flag to enable creating sparse files, and then have the application tell us what to do for any given range.

Anna

> 
> Note cp(1) has --sparse={never,auto,always}. Auto is the default,
> so it would be good I think if that was the default mode for copy_file_range().
> With other sparse modes, we'd have to avoid copy_file_range() unless
> there was control possible with COPY_FR_SPARSE_{AUTO,NONE,ALWAYS}.
> Note currently cp --sparse=always will detect runs of zeros and also
> avoid speculative preallocation by using fallocate (fd, FALLOC_FL_PUNCH_HOLE, ...)
> 
> thanks,
> Pádraig.
> 


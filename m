Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:17500 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421AbcEQRwV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2016 13:52:21 -0400
Subject: Re: [PATCH 1/5] src/copy_file_range: Add a program for testing
 vfs_copy_file_range()
To: "Darrick J. Wong" <darrick.wong@oracle.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
References: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1463172652-22361-2-git-send-email-Anna.Schumaker@Netapp.com>
 <20160516232036.GT26977@dastard>
 <4fbb6f1b-5c7f-7afe-b414-0f213870a328@Netapp.com>
 <20160517174830.GA4507@birch.djwong.org>
CC: Dave Chinner <david@fromorbit.com>, <fstests@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <hch@infradead.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <0a21c0ef-626c-821b-e30c-5b05edb87a02@Netapp.com>
Date: Tue, 17 May 2016 13:52:11 -0400
MIME-Version: 1.0
In-Reply-To: <20160517174830.GA4507@birch.djwong.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/17/2016 01:48 PM, Darrick J. Wong wrote:
> On Tue, May 17, 2016 at 10:47:42AM -0400, Anna Schumaker wrote:
>> On 05/16/2016 07:20 PM, Dave Chinner wrote:
>>> On Fri, May 13, 2016 at 04:50:48PM -0400, Anna Schumaker wrote:
>>>> This will be used by the various copy tests to call the Linux
>>>> copy_file_range() system call.  I used src/cloner.c as a reference while
>>>> writing this tool.
>>>
>>> Hmmm - I'd much prefer to see this added to xfs_io as it's a kernel
>>> syscall that lots of filesystems will eventually implement. A
>>> one-off binary for xfstests is fine for non-standard or deeply
>>> filesysetm specific stuff, but if it's generic we try to put it into
>>> xfs_io so that it's available to everyone writing scripts, not just
>>> xfstests....
>>
>> Ah, that makes sense.  Thanks for explaining the convention!  I'll look into
>> adding it to the xfs_io program instead.  Should I send that patch to a
>> different mailing list than fstests@vger.kernel.org?
> 
> xfs@oss.sgi.com.  I recommend looking at io/reflink.c as a template.
> 
> FWIW I'd also appreciate c_f_r being wired up in xfs_io.

I'm working on it right now!  I just finished fighting autotolls to get it to recognize a new file defining the "copy_range" command.  Hopefully porting everything over won't be too difficult from here.

Thanks for the suggestion to look at reflink!

Anna

> 
> --D
> 
>>
>> Thanks,
>> Anna
>>
>>>
>>> Cheers,
>>>
>>> Dave.
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe fstests" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


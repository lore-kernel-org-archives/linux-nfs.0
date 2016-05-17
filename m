Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:57763 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752569AbcEQOrq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2016 10:47:46 -0400
Subject: Re: [PATCH 1/5] src/copy_file_range: Add a program for testing
 vfs_copy_file_range()
To: Dave Chinner <david@fromorbit.com>
References: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1463172652-22361-2-git-send-email-Anna.Schumaker@Netapp.com>
 <20160516232036.GT26977@dastard>
CC: <fstests@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <4fbb6f1b-5c7f-7afe-b414-0f213870a328@Netapp.com>
Date: Tue, 17 May 2016 10:47:42 -0400
MIME-Version: 1.0
In-Reply-To: <20160516232036.GT26977@dastard>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/16/2016 07:20 PM, Dave Chinner wrote:
> On Fri, May 13, 2016 at 04:50:48PM -0400, Anna Schumaker wrote:
>> This will be used by the various copy tests to call the Linux
>> copy_file_range() system call.  I used src/cloner.c as a reference while
>> writing this tool.
> 
> Hmmm - I'd much prefer to see this added to xfs_io as it's a kernel
> syscall that lots of filesystems will eventually implement. A
> one-off binary for xfstests is fine for non-standard or deeply
> filesysetm specific stuff, but if it's generic we try to put it into
> xfs_io so that it's available to everyone writing scripts, not just
> xfstests....

Ah, that makes sense.  Thanks for explaining the convention!  I'll look into adding it to the xfs_io program instead.  Should I send that patch to a different mailing list than fstests@vger.kernel.org?

Thanks,
Anna

> 
> Cheers,
> 
> Dave.
> 


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46883 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbcEQRtF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2016 13:49:05 -0400
Date: Tue, 17 May 2016 10:48:30 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Dave Chinner <david@fromorbit.com>, fstests@vger.kernel.org,
        linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 1/5] src/copy_file_range: Add a program for testing
 vfs_copy_file_range()
Message-ID: <20160517174830.GA4507@birch.djwong.org>
References: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1463172652-22361-2-git-send-email-Anna.Schumaker@Netapp.com>
 <20160516232036.GT26977@dastard>
 <4fbb6f1b-5c7f-7afe-b414-0f213870a328@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4fbb6f1b-5c7f-7afe-b414-0f213870a328@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 17, 2016 at 10:47:42AM -0400, Anna Schumaker wrote:
> On 05/16/2016 07:20 PM, Dave Chinner wrote:
> > On Fri, May 13, 2016 at 04:50:48PM -0400, Anna Schumaker wrote:
> >> This will be used by the various copy tests to call the Linux
> >> copy_file_range() system call.  I used src/cloner.c as a reference while
> >> writing this tool.
> > 
> > Hmmm - I'd much prefer to see this added to xfs_io as it's a kernel
> > syscall that lots of filesystems will eventually implement. A
> > one-off binary for xfstests is fine for non-standard or deeply
> > filesysetm specific stuff, but if it's generic we try to put it into
> > xfs_io so that it's available to everyone writing scripts, not just
> > xfstests....
> 
> Ah, that makes sense.  Thanks for explaining the convention!  I'll look into
> adding it to the xfs_io program instead.  Should I send that patch to a
> different mailing list than fstests@vger.kernel.org?

xfs@oss.sgi.com.  I recommend looking at io/reflink.c as a template.

FWIW I'd also appreciate c_f_r being wired up in xfs_io.

--D

> 
> Thanks,
> Anna
> 
> > 
> > Cheers,
> > 
> > Dave.
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

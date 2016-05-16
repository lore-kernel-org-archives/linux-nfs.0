Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail05.adl6.internode.on.net ([150.101.137.143]:37389 "EHLO
	ipmail05.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751266AbcEPXVg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2016 19:21:36 -0400
Date: Tue, 17 May 2016 09:20:36 +1000
From: Dave Chinner <david@fromorbit.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 1/5] src/copy_file_range: Add a program for testing
 vfs_copy_file_range()
Message-ID: <20160516232036.GT26977@dastard>
References: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1463172652-22361-2-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1463172652-22361-2-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 13, 2016 at 04:50:48PM -0400, Anna Schumaker wrote:
> This will be used by the various copy tests to call the Linux
> copy_file_range() system call.  I used src/cloner.c as a reference while
> writing this tool.

Hmmm - I'd much prefer to see this added to xfs_io as it's a kernel
syscall that lots of filesystems will eventually implement. A
one-off binary for xfstests is fine for non-standard or deeply
filesysetm specific stuff, but if it's generic we try to put it into
xfs_io so that it's available to everyone writing scripts, not just
xfstests....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

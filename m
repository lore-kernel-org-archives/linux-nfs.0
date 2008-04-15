From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RFC/Patch: Make NFS Readahead tunable
Date: Tue, 15 Apr 2008 12:12:32 -0400
Message-ID: <1208275952.10759.12.camel@heimdal.trondhjem.org>
References: <975253.58176.qm@web32607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
To: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:50867 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537AbYDOQMf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Apr 2008 12:12:35 -0400
In-Reply-To: <975253.58176.qm-f6uctMgKLEavuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-04-15 at 06:39 -0700, Martin Knoblauch wrote:
> Hi,
> 
>  while tracking down a very interesting interaction between Sun/SAM-FS and Linux NFS clients, we found out that the value of NFS_MAX_READ_AHEAD is to agressive/big for the specific use-case.
> 
>  For testing, instead of always recompiling the kernel with different values, I came up with the following patch. It introduces a tunable  "/proc/sys/fs/nfs/nfs_ra_factor" with possible values between 0-15.
> 
>  Not sure whether it is actually a good thing to have. Better would be to set the read-ahead factor per filesystem via a mount option.
> 
>  The patch is against 2.6.24. It applies with offsets against 2.6.25-rc9. In case my mail client messes up the whitespace, the patch is also attached.

NFS_MAX_READ_AHEAD just sets an upper limit on the standard vfs/mm-level
page readahead algorithm. If you need finer control over that readahead
algorithm, then the kernel already has full support for the
posix_fadvise() system call.

Cheers
  Trond


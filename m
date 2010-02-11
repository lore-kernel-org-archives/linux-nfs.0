From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/2] commit_metadata export operation v3
Date: Thu, 11 Feb 2010 14:43:19 -0500
Message-ID: <1265917399.478.37.camel@localhost>
References: <20100211192611.12949.65493.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: Ben Myers <bpm@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:54764 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756405Ab0BKTnZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Feb 2010 14:43:25 -0500
In-Reply-To: <20100211192611.12949.65493.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-02-11 at 13:26 -0600, Ben Myers wrote: 
> Here is the latest version of the knfsd sync changes.  I have addressed the
> suggestions provided by Christoph, Trond, and Dave.
> 
> Thanks,
> 	Ben

Hi Ben,

This looks good to me, but before you send it on to Bruce, you might
want to try rebasing this against his for-2.6.34 branch. That branch
contains the stuff that is queued up for the next merge window, and
includes Christoph's vfs_fsync() changes and my vfs_fsync_range() change
to nfsd_commit().

See
http://git.linux-nfs.org/?p=bfields/linux.git;a=shortlog;h=refs/heads/for-2.6.34

Cheers
  Trond


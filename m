Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:30785 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756075Ab1KPCQU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Nov 2011 21:16:20 -0500
From: <tao.peng@emc.com>
To: <neilb@suse.de>, <josef@redhat.com>
CC: <linux-nfs@vger.kernel.org>, <jack@suse.cz>, <viro@zeniv.linux.org.uk>,
        <linux-fsdevel@vger.kernel.org>, <Trond.Myklebust@netapp.com>
Date: Tue, 15 Nov 2011 21:14:18 -0500
Subject: RE: [PATCH] NFS - fix recent breakage to NFS error handling.
Message-ID: <F19688880B763E40B28B2B462677FBF805DD0550DB@MX09A.corp.emc.com>
References: <20111116114631.3bf69abf@notabene.brown>
In-Reply-To: <20111116114631.3bf69abf@notabene.brown>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
> On Behalf Of NeilBrown
> Sent: Wednesday, November 16, 2011 8:47 AM
> To: Trond Myklebust
> Cc: NFS; Josef Bacik; Jan Kara; Al Viro
> Subject: [PATCH] NFS - fix recent breakage to NFS error handling.
> 
> From c6d615d2b97fe305cbf123a8751ced859dca1d5e Mon Sep 17 00:00:00 2001
> From: NeilBrown <neilb@suse.de>
> Date: Wed, 16 Nov 2011 09:39:05 +1100
> Subject: [PATCH] NFS - fix recent breakage to NFS error handling.
> 
> commit 02c24a82187d5a628c68edfe71ae60dc135cd178 made a small and
> presumably unintended change to write error handling in NFS.
> 
> Previously an error from filemap_write_and_wait_range would only be of interest if
> nfs_file_fsync did not return an error.  After this commit, an error from
> filemap_write_and_wait_range would mean that (the rest of) nfs_file_fsync would
> not even be called.
Do we need more consideration on commit 02c24a82187d5a628c68edfe71ae60dc135cd178?
Before it, vfs_fsync_range() calls f_op->fsync() regardless of filemap_write_and_wait_range() errors. After commit 02c24a82187d5a628c68edfe71ae60dc135cd178, it only calls f_op->fsync() when filemap_write_end_and_wait_range() succeeds. So the change is not really trivial to all file systems.

Thanks,
Tao


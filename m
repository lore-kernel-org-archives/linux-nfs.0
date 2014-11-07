Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36235 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766AbaKGVWh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Nov 2014 16:22:37 -0500
Date: Fri, 7 Nov 2014 16:22:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 0/3] NFS: Add ALLOCATE and DEALLOCATE support
Message-ID: <20141107212235.GB5723@fieldses.org>
References: <1415389467-16547-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1415389467-16547-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 07, 2014 at 02:44:24PM -0500, Anna.Schumaker@netapp.com wrote:
> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> These patches add client support for the ALLOCATE and DEALLOCATE operations
> part of NFS v4.2, which are triggered by a vfs_fallocate() call.
> 
> Changes in v4:
> - Check if we are modifying a regular file, and return nfserr_inval if not.

Thanks, applying for 3.19 (with minor change noted on patch 2.)

--b.

> 
> These patches and the corresponding server changes are available in the
> [fallocate] branch of
> 
> 	git://git.linux-nfs.org/projects/anna/linux-nfs.git
> 
> Questions?  Comments?  Thougts?
> 
> Anna
> 
> 
> Anna Schumaker (3):
>   VFS: Rename do_fallocate() to vfs_fallocate()
>   nfsd: Add ALLOCATE support
>   nfsd: Add DEALLOCATE support
> 
>  drivers/staging/android/ashmem.c |  2 +-
>  fs/ioctl.c                       |  2 +-
>  fs/nfsd/nfs4proc.c               | 51 ++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfs4xdr.c                | 21 +++++++++++++++--
>  fs/nfsd/vfs.c                    | 23 ++++++++++++++++++
>  fs/nfsd/vfs.h                    |  2 ++
>  fs/nfsd/xdr4.h                   |  9 +++++++
>  fs/open.c                        |  5 ++--
>  include/linux/fs.h               |  2 +-
>  mm/madvise.c                     |  2 +-
>  10 files changed, 111 insertions(+), 8 deletions(-)
> 
> -- 
> 2.1.3
> 

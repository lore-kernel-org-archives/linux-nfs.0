Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40933 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841AbbJBOpV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Oct 2015 10:45:21 -0400
Date: Fri, 2 Oct 2015 10:45:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: andros@netapp.com
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version 2 00/16] NFSv4.2: Add support for inter-server to
 server COPY
Message-ID: <20151002144520.GA15612@fieldses.org>
References: <1441387778-16465-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1441387778-16465-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apologies for the slow response.  I'm waiting to review this carefully
until the simpler (single-server) case is done.

Eventually I'd be curious for any performance results, specifically:

	- when copying a large file, is the copy able to use all the
	  available server<->server bandwidth?
	- when copying a small file, how does COPY compare to a read and
	  a write?

--b.

On Fri, Sep 04, 2015 at 01:29:22PM -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Version 2:
> 
> Fixed xdr issues. 
> Fixed stateid issues
> Added lease time to copy_notify return 
> 
> 
> Version 1: 
> These patches add client and server support for NFSv4.2 inter-server to
> server copy offload. These patches build upon Anna Schumaker's COPY Operation
> patches which are in turn built upon Zack Brown's VFS vfs_copy_file_range
> syscall. Additional functionality is added to the COPY operation past what
> Anna added. The COPY_NOTIFY operation is added.
> 
> The first three patches change Zach Brown's vfs_copy_file_range implementation.
> The first two patches relax the check for only performing copy offload between
> files with the same mount and super block, moving that check into a helper
> function that can be called (e.g. BTRFS) in a file systems copy_file_range
> function. The third patch changes vfs_copy_file_range to call the destination
> file (file_out) copy_file_range f_ops proceedure instead of the file_in version.
> 
> The remaining patches implement the COPY_NOTIFY operation and the inter-ssc
> changes to the COPY operation.  One source server using NL4_NETADDR is
> currently supported. I used the test program from Anna's COPY
> operation patch set.
> 
> 
> 
> Andy Adamson (12):
>   VFS: Separate cross fs check from vfs_copy_file_range
>   BTRFS: Use VFS copy offload helper
>   VFS SQUASH use file_out instead of file_in for copy_file_range
>   NFS add same file check and flush source and destination for COPY
>   NFS add inter ssc functions to nfs42proc
>   NFS add COPY_NOTIFY operation
>   NFSD add ca_source_server<> to COPY
>   NFSD add COPY_NOTIFY operation
>   NFS add ca_source_server<> to COPY
>   NFSD generalize nfsd4_compound_state flag names
>   NFSD: allow inter server COPY to have a STALE source server fh
>   NFSD add nfs4 inter ssc to nfsd4_copy
> 
> Olga Kornievskaia (4):
>   NFS COPY xdr changes
>   NFS in copy use stateid returned by copy_notify
>   NFS always use openstateid in COPY_NOTIFY
>   NFSD: extra stateid checking in read for interserver copy
> 
>  fs/btrfs/ioctl.c              |   3 +
>  fs/nfs/nfs42.h                |   2 +-
>  fs/nfs/nfs42proc.c            | 238 +++++++++++++++++++++-
>  fs/nfs/nfs42xdr.c             | 213 +++++++++++++++++++-
>  fs/nfs/nfs4_fs.h              |   9 +-
>  fs/nfs/nfs4file.c             |  17 +-
>  fs/nfs/nfs4proc.c             |   8 +-
>  fs/nfs/nfs4state.c            |   2 +-
>  fs/nfs/nfs4xdr.c              |   1 +
>  fs/nfsd/Kconfig               |  10 +
>  fs/nfsd/nfs4proc.c            | 456 +++++++++++++++++++++++++++++++++++++++++-
>  fs/nfsd/nfs4state.c           |  37 +++-
>  fs/nfsd/nfs4xdr.c             | 203 ++++++++++++++++++-
>  fs/nfsd/nfsd.h                |   2 +
>  fs/nfsd/state.h               |   8 +
>  fs/nfsd/xdr4.h                |  29 ++-
>  fs/read_write.c               |  38 ++--
>  include/linux/fs.h            |   1 +
>  include/linux/nfs4.h          |   7 +
>  include/linux/nfs4intercopy.h |  39 ++++
>  include/linux/nfs_fs_sb.h     |   1 +
>  include/linux/nfs_xdr.h       |  28 +++
>  22 files changed, 1289 insertions(+), 63 deletions(-)
>  create mode 100644 include/linux/nfs4intercopy.h
> 
> -- 
> 1.8.3.1

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39394 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754906AbbCRSvl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Mar 2015 14:51:41 -0400
Date: Wed, 18 Mar 2015 14:51:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: andros@netapp.com
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] NFSv4.2 Inter server to server copy RFC
Message-ID: <20150318185141.GE8818@fieldses.org>
References: <1426631498-14772-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1426631498-14772-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 17, 2015 at 06:31:28PM -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Disclaimer: this code is in early development. Please excuse printk's etc.
> 
> This RFC is for us to determine if there are objections, suggestions, or comments on our approach.  This code builds on top of Anna's intra-server copy patch set which uses the new vfs_copy_file_range call. This code can perform an inter-ssc copy using NFSv4.1 as the copy protocol; the destination server loads the nfs42-interserver-copy module, mounts the source server, sets up an NFS filep to pass to vfs_copy_file_range which READs the file to be copied over NFSv4.1. The destination server then cleans up. Multiple copies do not currently work.
> 
> Objectives:
> -----------
> 
> - Use NFSv4.1 for the copy protocol betweent the source and destination servers to READ the data to be copied.
> - Call the new vfs_copy_file_range function.
> - Do not call NFSv4.1 OPEN from the destination server. Instead, use the COPY ca_src_stateid and the COPY SAVE_FH filehandle, which are the file handle and stateid from the OPEN on the client by the user.
> 
> Some questions
> --------------
> 1) NFS interserver copy module
> 
> The basic design is for the destination server to load a new nfs42-interserver-copy NFS kernel module to setup the struct filp for vfs_copy_file_range to use.
> - We prefer the 'load NFS module' design to other designs such as an upcall to a userland daemon. Comments?

I'm fine with doing it in the kernel.  I don't think it's especially
important that it be its own module.  You do need an upcall for the name
resolution, though--the referral code does this already, doesn't it?  In
which case, copy whatever it does....

Or maybe consider dropping those cases from the protocol--why do we need
the NL4_NAME case?  And NL4_URL is even more cases to handle.  In
practice the implementations are all going to settle on one protocol if
they want to interoperate anyway.

If we really want to be able to handle http, ftp, or any other random
protocol, then that would be an argument for doing more in userspace,
but it would be simpler just to pick one.

--b.

> 2) NFS module connecting to the source server.
> 
> The module calls nfs_fs_mount using the NL4_NETADDR address in string form concatenated with ":/".
> We need to end up with a struct file that represents an NFSv4.1 open file to use for the READ. The alloc_file function requires a vfsmount struct in the struct path argument.
> Patch "NFS return the root_mnt via the raw data in nfs_fs_mount" makes the vfsmount struct from nfs_fs_mount available.
> 
> Comments on this approach?
> 
> Thanks
> 
> Andy Adamson
> 
> 
> Andy Adamson (10):
>   NFS return the root_mnt via the raw data in nfs_fs_mount
>   NFS interserver ssc module
>   NFS add COPY_NOTIFY operation
>   NFSD add ca_source_server<> to COPY
>   NFSD add COPY_NOTIFY operation
>   NFS add ca_source_server<> to COPY
>   NFSD generalize nfsd4_compound_state flag names
>   NFSD: allow inter server COPY to have a STALE source server fh
>   NFSD: add nfs4interssc.c
>   NFSD nfs4 inter ssc copy
> 
>  fs/nfs/Kconfig                  |  10 +
>  fs/nfs/Makefile                 |   3 +
>  fs/nfs/internal.h               |  16 ++
>  fs/nfs/nfs42.h                  |   5 +-
>  fs/nfs/nfs42proc.c              |  77 +++++++-
>  fs/nfs/nfs42xdr.c               | 196 ++++++++++++++++++-
>  fs/nfs/nfs4_fs.h                |   1 +
>  fs/nfs/nfs4client.c             |  30 +++
>  fs/nfs/nfs4file.c               |  32 ++-
>  fs/nfs/nfs4intercopy.c          | 419 ++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/nfs4proc.c               |   8 +-
>  fs/nfs/nfs4state.c              |   3 +
>  fs/nfs/nfs4super.c              |   2 +
>  fs/nfs/nfs4xdr.c                |   1 +
>  fs/nfs/super.c                  |  27 +++
>  fs/nfsd/Makefile                |   2 +-
>  fs/nfsd/nfs4interssc.c          | 110 +++++++++++
>  fs/nfsd/nfs4proc.c              | 307 ++++++++++++++++++++++++++++-
>  fs/nfsd/nfs4state.c             |   6 +-
>  fs/nfsd/nfs4xdr.c               | 180 ++++++++++++++++-
>  fs/nfsd/nfsd.h                  |   2 +
>  fs/nfsd/xdr4.h                  |  40 +++-
>  include/linux/nfs4.h            |   7 +
>  include/linux/nfs4intercopy.h   |  44 +++++
>  include/linux/nfs_fs_sb.h       |   1 +
>  include/linux/nfs_xdr.h         |  54 ++++++
>  include/uapi/linux/nfs4_mount.h |   1 +
>  27 files changed, 1548 insertions(+), 36 deletions(-)
>  create mode 100644 fs/nfs/nfs4intercopy.c
>  create mode 100644 fs/nfsd/nfs4interssc.c
>  create mode 100644 include/linux/nfs4intercopy.h
> 
> -- 
> 1.8.3.1

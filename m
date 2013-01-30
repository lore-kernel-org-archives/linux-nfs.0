Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45863 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754467Ab3A3WLU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jan 2013 17:11:20 -0500
Date: Wed, 30 Jan 2013 17:11:18 -0500
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Subject: Re: [PATCH v2 0/8] Add O_DENY* support for VFS and CIFS/NFS
Message-ID: <20130130221118.GB15584@fieldses.org>
References: <1358441537-8672-1-git-send-email-piastry@etersoft.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1358441537-8672-1-git-send-email-piastry@etersoft.ru>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 17, 2013 at 08:52:09PM +0400, Pavel Shilovsky wrote:
> This patchset adds support of O_DENY* flags for Linux fs layer. These flags can be used by any application that needs share reservations to organize a file access. VFS already has some sort of this capability - now it's done through flock/LOCK_MAND mechanis, but that approach is non-atomic. This patchset build new capabilities on top of the existing one but doesn't bring any changes into the flock call semantic.
> 
> These flags can be used by NFS (built-in-kernel) and CIFS (Samba) servers and Wine applications through VFS (for local filesystems) or CIFS/NFS modules. This will help when e.g. Samba and NFS server share the same directory for Windows and Linux users or Wine applications use Samba/NFS share to access the same data from different clients.
> 
> According to the previous discussions the most problematic question is how to prevent situations like DoS attacks where e.g /lib/liba.so file can be open with DENYREAD, or smth like this. That's why one extra flag O_DENYMAND is added. It indicates to underlying layer that an application want to use O_DENY* flags semantic. It allows us not affect native Linux applications (that don't use O_DENYMAND flag) - so, these flags (and the semantic of open syscall that they bring) are used only for those applications that really want it proccessed that way.

Maybe that's good enough.  A mount flag might be simpler and give
consistent enforcement for all users.

> 
> So, we have four new flags:
> O_DENYREAD - to prevent other opens with read access,
> O_DENYWRITE - to prevent other opens with write access,
> O_DENYDELETE - to prevent delete operations (this flag is not implemented in VFS and NFS part and only suitable for CIFS module),
> O_DENYMAND - to switch on/off three flags above.

It would be useful to have some really careful documentation of how
these are meant to work.  Maybe try updating the open man page?

--b.
> 
> The #1 patch bring infrastructure to let us add this capability easier. #2 patch adds flags to fcntl while #3 patch implement VFS part. Patches #4, #5, #6 are related to CIFS-specific changes. #7 and #8 describe NFS and NFSD parts.
> 
> Also, I created the preliminary patch for Samba that replaces the existing use of flock/LOCK_MAND mechanism with O_DENY* flags:
> http://git.etersoft.ru/people/piastry/packages/?p=samba.git;a=commitdiff;h=f116c478bf9a1bc3985e9a719fb20d854914d67a
> 
> Pavel Shilovsky (8):
>   locks: make flock_lock_file take is_conflict callback parm
>   fcntl: Introduce new O_DENY* open flags
>   vfs: Add O_DENYREAD/WRITE flags support for open syscall
>   CIFS: Add O_DENY* open flags support
>   CIFS: Use NT_CREATE_ANDX command for forcemand mounts
>   CIFS: Translate SHARING_VIOLATION to -ETXTBSY error code for SMB2
>   NFSv4: Add O_DENY* open flags support
>   NFSD: Pass share reservations flags to VFS
> 
>  fs/cifs/cifsacl.c                |  10 ++--
>  fs/cifs/cifsglob.h               |  12 +++-
>  fs/cifs/cifsproto.h              |   9 +--
>  fs/cifs/cifssmb.c                |  47 ++++++++-------
>  fs/cifs/dir.c                    |  14 +++--
>  fs/cifs/file.c                   |  18 ++++--
>  fs/cifs/inode.c                  |  11 ++--
>  fs/cifs/link.c                   |  10 ++--
>  fs/cifs/readdir.c                |   2 +-
>  fs/cifs/smb1ops.c                |  15 ++---
>  fs/cifs/smb2file.c               |  10 ++--
>  fs/cifs/smb2inode.c              |   4 +-
>  fs/cifs/smb2maperror.c           |   2 +-
>  fs/cifs/smb2ops.c                |  10 ++--
>  fs/cifs/smb2pdu.c                |   6 +-
>  fs/cifs/smb2proto.h              |  14 +++--
>  fs/fcntl.c                       |   5 +-
>  fs/locks.c                       | 121 ++++++++++++++++++++++++++++++++++++---
>  fs/namei.c                       |  10 +++-
>  fs/nfs/nfs4xdr.c                 |  24 ++++++--
>  fs/nfsd/nfs4state.c              |  46 ++++++++++++++-
>  include/linux/fs.h               |   6 ++
>  include/uapi/asm-generic/fcntl.h |  14 +++++
>  23 files changed, 324 insertions(+), 96 deletions(-)
> 
> -- 
> 1.8.1.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

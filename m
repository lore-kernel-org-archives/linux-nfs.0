Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:44094 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753321AbeCTNKD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Mar 2018 09:10:03 -0400
Message-ID: <1521551400.4686.19.camel@kernel.org>
Subject: Re: [PATCH 00/10] Eliminate delegation self-conflicts v2
From: Jeff Layton <jlayton@kernel.org>
To: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Tue, 20 Mar 2018 09:10:00 -0400
In-Reply-To: <1521470194-24840-1-git-send-email-bfields@redhat.com>
References: <1521470194-24840-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2018-03-19 at 10:36 -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> This is my second attempt to fix the NFS server so we don't
> unnecessarily recall delegations when the operation breaking the
> delegation comes from the same client that holds the delegation.
> 
> To do that we need some way to pass the identity of the breaker down
> through the VFS.  In my first attempt I tried passing that explicitly,
> but that touches a lot of code.  So instead I'm experimenting with
> adding a field to the cred struct.
> 
> Testing has confirmed that this works.  (And that the pynfs tests are
> broken--they *require* the server to break delegations on operations
> coming from the client, even though that's the less desireable behavior.
> I'm fixing that...).
> 
> J. Bruce Fields (10):
>   vfs: remove unnecessary fl_owner_t typedef
>   nfsd: simplify put of fi_deleg_file
>   nfsd: simplify nfs4_put_deleg_lease calls
>   nfsd4: set fl_owner to delegation, not file pointer
>   nfsd4: dp->dl_stid.sc_file doesn't need locking
>   nfsd: make nfs4_get_existing_delegation less confusing
>   nfsd: factor out common delegation-destruction code
>   nfsd: move sc_file assignment into alloc_init_deleg
>   nfsd: create a separate lease for each delegation
>   nfsd: clients don't need to break their own delegations
> 
>  Documentation/filesystems/Locking          |   2 +
>  Documentation/filesystems/vfs.txt          |   2 +-
>  arch/ia64/kernel/perfmon.c                 |   2 +-
>  arch/powerpc/platforms/cell/spufs/file.c   |   2 +-
>  arch/tile/kernel/hardwall.c                |   2 +-
>  drivers/android/binder.c                   |   2 +-
>  drivers/char/ps3flash.c                    |   2 +-
>  drivers/char/xillybus/xillybus_core.c      |   2 +-
>  drivers/firmware/efi/capsule-loader.c      |   2 +-
>  drivers/input/evdev.c                      |   2 +-
>  drivers/misc/mic/scif/scif_fd.c            |   2 +-
>  drivers/scsi/osst.c                        |   2 +-
>  drivers/scsi/st.c                          |   2 +-
>  drivers/staging/lustre/lustre/llite/file.c |   2 +-
>  drivers/usb/class/cdc-wdm.c                |   2 +-
>  drivers/usb/usb-skeleton.c                 |   2 +-
>  fs/afs/internal.h                          |   2 +-
>  fs/afs/write.c                             |   2 +-
>  fs/cifs/cifsfs.h                           |   2 +-
>  fs/cifs/file.c                             |   4 +-
>  fs/ecryptfs/file.c                         |   2 +-
>  fs/exofs/file.c                            |   2 +-
>  fs/f2fs/file.c                             |   2 +-
>  fs/fuse/file.c                             |  13 +-
>  fs/fuse/fuse_i.h                           |   2 +-
>  fs/lockd/clntproc.c                        |   4 +-
>  fs/lockd/svc4proc.c                        |   2 +-
>  fs/lockd/svcproc.c                         |   2 +-
>  fs/locks.c                                 |   6 +-
>  fs/nfs/file.c                              |   2 +-
>  fs/nfs/inode.c                             |   2 +-
>  fs/nfs/nfs4_fs.h                           |   2 +-
>  fs/nfs/nfs4file.c                          |   2 +-
>  fs/nfs/nfs4state.c                         |   8 +-
>  fs/nfsd/auth.c                             |   2 +
>  fs/nfsd/nfs4proc.c                         |   1 +
>  fs/nfsd/nfs4state.c                        | 267 ++++++++++++-----------------
>  fs/nfsd/nfssvc.c                           |   1 +
>  fs/notify/dnotify/dnotify.c                |   6 +-
>  fs/open.c                                  |   2 +-
>  include/linux/cred.h                       |   3 +
>  include/linux/dnotify.h                    |   6 +-
>  include/linux/fs.h                         |  18 +-
>  include/linux/lockd/lockd.h                |   4 +-
>  include/linux/nfs_fs.h                     |   4 +-
>  include/linux/sunrpc/svc.h                 |   1 +
>  include/trace/events/filelock.h            |   6 +-
>  ipc/mqueue.c                               |   2 +-
>  48 files changed, 193 insertions(+), 223 deletions(-)
> 

Nice work.

The whole first part of the series looks like a nice set of cleanups
(sans the first patch, as there seems to be support to keep fl_owner_t
typedef around). Giving each delegation its own lease makes a lot more
sense, IMO.

On patches 2-9, you can add:

    Reviewed-by: Jeff Layton <jlayton@kernel.org>

...and maybe get those into -next soon? The delegation code has been a
source of subtle bugs in the past, so we really want this to get a lot
of testing.

With patch 10, I have some concern about growing a common structure like
struct cred with such a special-purpose field.

An alternative might be to utilize the keyrings there -- maybe stash a
special sort of key on one of the keyrings with this pointer? We'd need
to take care to prevent userland from doing this, but that seems like a
solvable problem.

Cheers,
-- 
Jeff Layton <jlayton@kernel.org>

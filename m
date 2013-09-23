Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:46609 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950Ab3IWRA4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Sep 2013 13:00:56 -0400
Received: by mail-ie0-f171.google.com with SMTP id at1so7173987iec.30
        for <linux-nfs@vger.kernel.org>; Mon, 23 Sep 2013 10:00:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130920150902.16220.32737.stgit@warthog.procyon.org.uk>
References: <20130920150902.16220.32737.stgit@warthog.procyon.org.uk>
Date: Mon, 23 Sep 2013 13:00:55 -0400
Message-ID: <CANP1eJFH234+98DORsQub+6kXuuYfN93=bCjVK8Q5gMWbohtCg@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/3] FS-Cache: NFS(/CIFS/Ceph/9P): Fix start-caching
 whilst writing race
From: Milosz Tanski <milosz@adfin.com>
To: David Howells <dhowells@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, steved@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "linux-cachefs@redhat.com" <linux-cachefs@redhat.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        ceph-devel <ceph-devel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This should not be a problem with Ceph as the MDS (the metadata
server) hands out cache capability bit for an inode. In this schema
there's no need to worry about the count of of local file pointers
open for write (or even across the cluster).

As an aside, the Ceph code checks if we can perform the requested VMA
operation by checking the valid_fscache generation (compared to the
current cache generation). This way we only create the cookie the
first time the file is open. This has greatly simplified the code and
got rid of a lot of races.

Best,
- Milosz

On Fri, Sep 20, 2013 at 11:09 AM, David Howells <dhowells@redhat.com> wrote:
>
>
> Following this mail is a series of patches to fix an issue with NFS whereby
> caching can be enabled on a file that is open for writing by subsequently
> opening it for reading.  This can be made to crash by opening it for writing
> again if you're quick enough.
>
> The patches mailed here may not apply directly.  They are based on top of three
> fix patches as can be seen in the GIT branch here:
>
>   http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=fscache
>
>
> The gist of the patchset is that the cookie should be acquired at inode
> creation only and subsequently enabled and disabled as appropriate (which
> dispenses with the backing objects when they're not needed).
>
> The extra synchronisation that NFS does can then be dispensed with as it is
> thenceforth managed by FS-Cache.
>
> This likely will need applying to CIFS, Ceph and 9P also once this is okayed
> for NFS.  AFS is probably safe.
>
> David
> ---
> David Howells (3):
>       FS-Cache: Add use/unuse/wake cookie wrappers
>       FS-Cache: Provide the ability to enable/disable cookies
>       NFS: Use i_writecount to control whether to get an fscache cookie in nfs_open()
>
>
>  Documentation/filesystems/caching/netfs-api.txt |   73 +++++++--
>  fs/9p/cache.c                                   |    6 -
>  fs/afs/cell.c                                   |    2
>  fs/afs/inode.c                                  |    2
>  fs/afs/vlocation.c                              |    3
>  fs/afs/volume.c                                 |    2
>  fs/cachefiles/interface.c                       |    2
>  fs/ceph/cache.c                                 |    4
>  fs/cifs/fscache.c                               |    8 -
>  fs/fscache/cookie.c                             |  193 +++++++++++++++++------
>  fs/fscache/fsdef.c                              |    1
>  fs/fscache/netfs.c                              |    1
>  fs/fscache/object.c                             |    7 +
>  fs/fscache/page.c                               |   59 +++++--
>  fs/nfs/dir.c                                    |    2
>  fs/nfs/fscache.c                                |  196 +++++++----------------
>  fs/nfs/fscache.h                                |   18 +-
>  fs/nfs/inode.c                                  |    6 -
>  fs/nfs/nfs4file.c                               |    2
>  include/linux/fs.h                              |    5 +
>  include/linux/fscache-cache.h                   |   50 ++----
>  include/linux/fscache.h                         |  113 ++++++++++++-
>  include/linux/nfs_fs.h                          |    8 +
>  23 files changed, 462 insertions(+), 301 deletions(-)
>
> --
> To unsubscribe from this list: send the line "unsubscribe ceph-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

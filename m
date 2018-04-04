Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56848 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751356AbeDDSkP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Apr 2018 14:40:15 -0400
Subject: Re: [PATCH net-next 0/3] fscache: quick review
To: David Howells <dhowells@redhat.com>, anna.schumaker@netapp.com
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-afs@lists.infradead.org
References: <152276719197.15943.8722265175158239235.stgit@warthog.procyon.org.uk>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <c0e6d7f2-e3ee-b80d-fbfa-b0c61b25aa43@RedHat.com>
Date: Wed, 4 Apr 2018 14:40:14 -0400
MIME-Version: 1.0
In-Reply-To: <152276719197.15943.8722265175158239235.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/03/2018 10:53 AM, David Howells wrote:
> 
> Hi Anna, Steve,
> 
> Could you give these three patches a quick look over?  They:
> 
>  (1) Modify the netfs->fscache API to store the index key, auxiliary data
>      and data size in the cookie/object rather than calling back into the
>      netfs - which reduces issues around making sure the netfs still
>      exists.
> 
>  (2) Keep a list of all the cookies known to weed out duplicate cookies at
>      the top.
> 
> I'd ideally like to try getting them into this merge window.
> 
> The patches can also be found on this branch on top of some other patches
> which add a few fixes and some tracepoints:
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=fscache-next
I took these patches and put them into a Fedora rawhide kernel.... 

They seem to work... Tested-by: Steve Dickson <steved@redhat.com>

steved.
> 
> Thanks,
> David
> ---
> David Howells (3):
>       fscache: Attach the index key and aux data to the cookie
>       fscache: Pass object size in rather than calling back for it
>       fscache: Maintain a catalogue of allocated cookies
> 
> 
>  Documentation/filesystems/caching/netfs-api.txt |  157 +++++------
>  fs/9p/cache.c                                   |  100 ++-----
>  fs/afs/cache.c                                  |  142 ----------
>  fs/afs/cell.c                                   |    6 
>  fs/afs/file.c                                   |    6 
>  fs/afs/inode.c                                  |   46 +++
>  fs/afs/internal.h                               |    7 
>  fs/afs/volume.c                                 |    6 
>  fs/cachefiles/interface.c                       |   43 ++-
>  fs/cachefiles/namei.c                           |   33 +-
>  fs/cachefiles/xattr.c                           |    8 -
>  fs/ceph/cache.c                                 |  113 ++------
>  fs/cifs/cache.c                                 |  168 ------------
>  fs/cifs/fscache.c                               |  130 +++++++--
>  fs/cifs/fscache.h                               |   13 +
>  fs/fscache/cache.c                              |    2 
>  fs/fscache/cookie.c                             |  336 +++++++++++++++++++----
>  fs/fscache/fsdef.c                              |   55 ----
>  fs/fscache/internal.h                           |   27 ++
>  fs/fscache/netfs.c                              |   23 --
>  fs/fscache/object-list.c                        |   28 +-
>  fs/fscache/object.c                             |   27 +-
>  fs/fscache/operation.c                          |    2 
>  fs/fscache/page.c                               |    5 
>  fs/nfs/fscache-index.c                          |  159 -----------
>  fs/nfs/fscache.c                                |   89 +++++-
>  fs/nfs/fscache.h                                |   15 +
>  include/linux/fscache-cache.h                   |    3 
>  include/linux/fscache.h                         |  141 ++++++----
>  include/trace/events/fscache.h                  |    6 
>  30 files changed, 926 insertions(+), 970 deletions(-)
> 

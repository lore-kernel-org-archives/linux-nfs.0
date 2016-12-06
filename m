Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44048 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753122AbcLFQa3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 11:30:29 -0500
Subject: Re: [PATCH 0/4] 4 assorted nfs-utils patches
To: NeilBrown <neilb@suse.com>
References: <148064084082.9179.6570593128436337540.stgit@noble>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <818a017b-d480-a47c-2c61-d2a16aad293c@RedHat.com>
Date: Tue, 6 Dec 2016 11:30:15 -0500
MIME-Version: 1.0
In-Reply-To: <148064084082.9179.6570593128436337540.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/01/2016 08:09 PM, NeilBrown wrote:
> First 2 are a repost of two I posted yesterday, with a small change
> following the response from Steve.
> 
> Third removes usage of the old nfsctl systemcall (which isn't
> available in current kernels, and probably hasn't been used by anyone
> in years).
> 
> The last cleans up some code that annoyed my while I was working on
> something else.
> 
> Thanks,
> NeilBrown
> 
> 
> ---
> 
> NeilBrown (4):
>       mount: don't hide temporary error code on timeout.
>       mount: take history into account when assessing if an error is permanent.
>       Remove all use of the nfsctl system call.
>       Remove error messages on xstrdup failure.
All 4 committed! thanks! 

steved.
> 
> 
>  support/export/Makefile.am |    2 -
>  support/export/export.c    |   56 ------------------
>  support/export/nfsctl.c    |  118 ---------------------------------------
>  support/export/rmtab.c     |   98 --------------------------------
>  support/export/xtab.c      |   16 -----
>  support/include/exportfs.h |    7 --
>  support/include/nfs/nfs.h  |  120 ---------------------------------------
>  support/include/nfslib.h   |   16 -----
>  support/nfs/Makefile.am    |    4 +
>  support/nfs/cacheio.c      |   12 ----
>  support/nfs/getfh.c        |  134 --------------------------------------------
>  support/nfs/nfsclient.c    |   34 -----------
>  support/nfs/nfsctl.c       |   32 -----------
>  support/nfs/nfsexport.c    |  134 --------------------------------------------
>  support/nfs/rmtab.c        |   21 -------
>  utils/exportfs/exportfs.c  |   84 +---------------------------
>  utils/mount/stropts.c      |   38 ++++++++++--
>  utils/mountd/auth.c        |   15 +----
>  utils/mountd/mountd.c      |   63 +++++----------------
>  utils/nfsd/nfsd.c          |   36 ++----------
>  utils/nfsd/nfssvc.c        |   26 ++-------
>  utils/nfsd/nfssvc.h        |    2 -
>  utils/nfsidmap/nfsidmap.c  |    6 --
>  utils/statd/statd.c        |    5 --
>  24 files changed, 67 insertions(+), 1012 deletions(-)
>  delete mode 100644 support/export/nfsctl.c
>  delete mode 100644 support/export/rmtab.c
>  delete mode 100644 support/nfs/getfh.c
>  delete mode 100644 support/nfs/nfsclient.c
>  delete mode 100644 support/nfs/nfsctl.c
>  delete mode 100644 support/nfs/nfsexport.c
> 
> --
> Signature
> 

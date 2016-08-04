Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55622 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752457AbcHDLuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2016 07:50:44 -0400
Subject: Re: [PATCH 0/7] Assorted mount/mountd nfs-utils patches - V2
To: NeilBrown <neilb@suse.com>
References: <146976807524.20186.8871903418718212567.stgit@noble>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <ebff995f-0de7-900f-d240-bd6dfc7d9930@RedHat.com>
Date: Thu, 4 Aug 2016 07:50:03 -0400
MIME-Version: 1.0
In-Reply-To: <146976807524.20186.8871903418718212567.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/29/2016 01:03 AM, NeilBrown wrote:
> Hi,
>  here is a revision of a recent patch series.
>  Thanks to Bruce's uncompromising review I have significantly reduced
>  the changes to mountpoint handling to just that which is needed.
> 
>  If we assume the NFSv3 behavior is "correct" (because it has been
>  that way for over a decade), the NFSv4 behavior differs
>  particularly in that a mount request arrives as a lookup from an
>  pseduo-root parent.  This is seen by rpc.mountd as an upcall through
>  nfsd.export.
>  The nfsd_export() handled was ignoring the mountpoint option, and
>  that is incorrect.  So a patch in this series handles the option correctly.
> 
>  The changes to blocking and ESTALE return, and the monitoring of
>  /proc/mounts have all been removed.
> 
>  It might be beneficial to change the kernel so that the reported
>  mtime of V4ROOT directories is that last time any change was made to
>  any V4ROOT export.  That might allow the client to see changes in
>  exports more quickly.
> 
>  It might also be generally useful for mountd to monitor /proc/mounts
>  (using e.g. select()) and flush the export cache shortly after any
>  changes.  Again, this would allow the client to see changes more
>  promptly.
> 
>  However I don't plan either of these immediately, which means they
>  almost certainly won't happen unless the issue is raised again for
>  some reason.
> 
> Thanks,
> NeilBrown
> 
> ---
> 
> NeilBrown (7):
>       nfs.man: clarify effect of 'retry' option.
>       mountd: remove the --exports-file option
>       mount: don't treat temporary name resolution failure as permanent.
>       mount: use a public address for IPv6 callback.
>       mount: fix memory leak in v4root_add_parents
>       mountd: allow alternate ttl to be specified for dump_to_cache.
>       mountd: fail nfsd.export lookup for path to unmounted exportpoint
The patch series committed... 

steved.

> 
> 
>  utils/mount/network.c   |    5 ++++
>  utils/mount/nfs.man     |   14 ++++++++++--
>  utils/mount/stropts.c   |   54 +++++++++++++++++++++++++++--------------------
>  utils/mountd/auth.c     |    5 +---
>  utils/mountd/cache.c    |   36 ++++++++++++++++++++++++-------
>  utils/mountd/mountd.c   |   11 +++-------
>  utils/mountd/mountd.h   |    2 +-
>  utils/mountd/mountd.man |    8 -------
>  utils/mountd/v4root.c   |    6 +++--
>  9 files changed, 84 insertions(+), 57 deletions(-)
> 
> --
> Signature
> 

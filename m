Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44772 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751960AbcG2TFn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2016 15:05:43 -0400
Date: Fri, 29 Jul 2016 15:05:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/7] Assorted mount/mountd nfs-utils patches - V2
Message-ID: <20160729190541.GC7964@fieldses.org>
References: <146976807524.20186.8871903418718212567.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <146976807524.20186.8871903418718212567.stgit@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ACK to the series.

On Fri, Jul 29, 2016 at 03:03:36PM +1000, NeilBrown wrote:
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

Makes sense, thanks.--b.

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

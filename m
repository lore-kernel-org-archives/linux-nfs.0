From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/7] Patches for nfs-utils-1.1.3
Date: Tue, 15 Jul 2008 15:30:56 -0400
Message-ID: <487CFAF0.9030403@RedHat.com>
References: <20080630170420.9905.90111.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60349 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756308AbYGOTbh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 15:31:37 -0400
In-Reply-To: <20080630170420.9905.90111.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> Please consider these patches to be part of nfs-utils-1.1.3.  They include a
> number of clean-ups, as well as support for the new "sloppy" option which
> should help automounter.  Kernel support for "sloppy" is in Trond's devel
> branch now, and should be upstream in 2.6.27.
> 
> The getaddrinfo(3) changes enable the mount.nfs and umount.nfs commands for
> IPv6 in the future, but should be harmless to include now.  I would like to
> know if there are any problems with this before we push forward with IPv6, so
> please consider this for 1.1.3.
> 
> ---
> 
> Chuck Lever (7):
>       text-based mount command: pass "sloppy" when -s is set
>       mount command: move function to get kernel version to separate header
>       mount: Introduce IPv6-aware DNS resolver API function
>       nfs-utils: Add dependency for getaddrinfo(3) in configure.ac
>       mount command: don't include headers multiple times
>       text-based mount command: Make "internal error" message more explicit
>       Python scripts:  Report bandwidth in "kB/s" instead of "Kb/s"
> 
> 
>  configure.ac                   |    3 ++
>  tools/mountstats/mountstats.py |    8 ++--
>  tools/nfs-iostat/nfs-iostat.py |    2 +
>  utils/mount/Makefile.am        |    2 +
>  utils/mount/error.c            |    7 +++-
>  utils/mount/error.h            |    5 +++
>  utils/mount/fstab.h            |    7 ++--
>  utils/mount/mount.c            |   18 +--------
>  utils/mount/mount_constants.h  |    6 ++-
>  utils/mount/network.c          |   78 ++++++++++++++++++++++++++++++----------
>  utils/mount/network.h          |    7 ++++
>  utils/mount/nfs_mount.h        |    6 ++-
>  utils/mount/nfsmount.c         |    5 +--
>  utils/mount/parse_opt.h        |    5 +++
>  utils/mount/stropts.c          |   22 ++++++++++-
>  utils/mount/stropts.h          |    5 +++
>  utils/mount/token.h            |    5 +++
>  utils/mount/version.h          |   51 ++++++++++++++++++++++++++
>  18 files changed, 183 insertions(+), 59 deletions(-)
>  create mode 100644 utils/mount/version.h
> 

All seven patches are committed...

steved.


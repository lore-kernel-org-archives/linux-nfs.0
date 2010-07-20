Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60380 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932485Ab0GUAnN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:43:13 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNV-0004K5-R0
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:38 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 00/24] Turn on the -Wextra compile flag
Date: Tue, 20 Jul 2010 19:37:13 -0400
Message-Id: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

To catch potential during compile time, the -Wextra compile flag
was added to the CFLAGS. The raise the bar like this, with regard to
warnings, will keep the code cleaner in the long run.

Steve Dickson (24):
  Enable extra compile warnings (-Wextra) by default.
  Remove warnings from nfsctl.c
  Removed warnings from rpcdispatch.c
  Remove warnings from svc_socket.c
  emove warnings from cacheio.c
  Remove warnings from nfs_mntent.c
  Removed warnings from conffile.c
  Removed warnings from mountd.c
  Removed warnings from fsloc.c
  Removed warnings from cache.c
  Removed warnings from nfssvc.c
  Removed warnings from nfsstat.c
  Removed warnings from atomicio.c
  Removed warnings from idmapd.c
  Removed warnings from gssd.c
  Removed warnings from gssd_main_loop.c
  Removed warnings from krb5_util.c
  Removed warnings from gssd_proc.c
  Removed warnings from svcgssd.c
  Removed warnings from svcgssd_proc.c
  Removed warnings from network.c
  Removed warnings from nfsmount.c
  Removed warnings from nfs4mount.c
  Removed warnings from configfile.c

 configure.ac                |    2 +-
 support/export/nfsctl.c     |    2 +-
 support/include/nfslib.h    |    4 ++--
 support/nfs/cacheio.c       |    2 +-
 support/nfs/conffile.c      |    8 ++++----
 support/nfs/nfs_mntent.c    |    2 +-
 support/nfs/rpcdispatch.c   |    4 ++--
 support/nfs/rpcmisc.c       |    2 +-
 support/nfs/svc_socket.c    |    6 +++---
 utils/gssd/gssd.c           |    2 +-
 utils/gssd/gssd_main_loop.c |    2 ++
 utils/gssd/gssd_proc.c      |    8 ++++----
 utils/gssd/krb5_util.c      |   29 +++++++++++++++++++++--------
 utils/gssd/krb5_util.h      |    2 +-
 utils/gssd/svcgssd.c        |    2 +-
 utils/gssd/svcgssd_proc.c   |    8 ++++----
 utils/idmapd/atomicio.c     |    3 ++-
 utils/idmapd/idmapd.c       |   36 +++++++++++++++++++++++++++++++-----
 utils/mount/configfile.c    |    4 ++--
 utils/mount/network.c       |   19 +++++++++----------
 utils/mount/nfs4mount.c     |    2 +-
 utils/mount/nfsmount.c      |    8 ++++++--
 utils/mountd/cache.c        |   20 ++++++++++----------
 utils/mountd/fsloc.c        |    2 +-
 utils/mountd/fsloc.h        |    2 +-
 utils/mountd/mountd.c       |   19 +++++++++++++++----
 utils/nfsd/nfssvc.c         |    6 +++---
 utils/nfsstat/nfsstat.c     |    6 +++---
 28 files changed, 134 insertions(+), 78 deletions(-)


From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 00/24] Turn on the -Wextra compile flag (Take 2)
Date: Wed,  4 Aug 2010 11:11:56 -0400
Message-ID: <1280934740-11366-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:54501 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751970Ab0HDPMY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:12:24 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Ogfdk-0002SZ-NC
	for linux-nfs@vger.kernel.org; Wed, 04 Aug 2010 11:12:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To catch potential during compile time, the -Wextra compile flag
was added to the CFLAGS. The raise the bar like this, with regard to
warnings, will keep the code cleaner in the long run.


Steve Dickson (24):
  Enable extra compile warnings (-Wextra) by default.
  Removed warnings from rpcdispatch.c
  Remove warnings from svc_socket.c
  emove warnings from cacheio.c
  Remove warnings from nfs_mntent.c
  Removed warnings from conffile.c
  Removed warnings from fsloc.c
  Removed warnings from cache.c
  Removed warnings from nfssvc.c
  Removed warnings from nfsstat.c
  Removed warnings from atomicio.c
  Removed warnings from gssd.c
  Removed warnings from gssd_main_loop.c
  Removed warnings from krb5_util.c
  Removed warnings from gssd_proc.c
  Removed warnings from svcgssd.c
  Removed warnings from nfsmount.c
  Removed warnings from nfs4mount.c
  Removed warnings from network.c
  Removed warnings from svcgssd_proc.c
  Removed warnings from configfile.c
  Removed warnings from idmapd.c
  Removed warnings from mountd.c
  Remove warnings from nfsctl.c

 configure.ac                |    2 +-
 support/export/nfsctl.c     |    2 +-
 support/include/nfslib.h    |    7 +++++--
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
 utils/gssd/svcgssd_proc.c   |   12 +++---------
 utils/idmapd/atomicio.c     |    3 ++-
 utils/idmapd/idmapd.c       |   36 ++++++++++++++++++++++++++----------
 utils/mount/configfile.c    |    6 ++++--
 utils/mount/network.c       |    3 ++-
 utils/mount/nfs4mount.c     |    2 +-
 utils/mount/nfsmount.c      |    8 ++++++--
 utils/mountd/cache.c        |   20 ++++++++++----------
 utils/mountd/fsloc.c        |    2 +-
 utils/mountd/fsloc.h        |    2 +-
 utils/mountd/mountd.c       |   14 ++++++++------
 utils/nfsd/nfssvc.c         |    6 +++---
 utils/nfsstat/nfsstat.c     |    6 +++---
 28 files changed, 119 insertions(+), 81 deletions(-)

-- 
1.7.2


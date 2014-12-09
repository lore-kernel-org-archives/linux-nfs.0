Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51256 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750998AbaLIFkw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:40:52 -0500
Subject: [PATCH 00/19] gssd improvements
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:40:40 +0100
Message-ID: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series converts gssd to use libevent and inotify instead
of a handrolled event loop and dnotify. Lots of cleanups in the process
(e.g. removing a lot of arbitrary limitations and fixed size buffers).

All in all a nice reduction in code size (what can I say, I was bored).

I've even managed to mount NFS shares with the patched server :)

---

David Härdeman (19):
      nfs-utils: cleanup daemonization code
      nfs-utils: gssd - merge gssd_main_loop.c and gssd.c
      nfs-utils: gssd - simplify some option handling
      nfs-utils: gssd - remove arbitrary GSSD_MAX_CCACHE_SEARCH limitation
      nfs-utils: gssd - simplify topdirs path
      nfs-utils: gssd - move over pipfs scanning code
      nfs-utils: gssd - simplify client dir scanning code
      nfs-utils: gssd - use libevent
      nfs-utils: gssd - remove "close me" code
      nfs-utils: gssd - make the client lists per-topdir
      nfs-utils: gssd - keep the rpc_pipefs dir open
      nfs-utils: gssd - use more relative paths
      nfs-utils: gssd - simplify topdir scanning
      nfs-utils: gssd - simplify client scanning
      nfs-utils: gssd - cleanup read_service_info
      nfs-utils: gssd - change dnotify to inotify
      nfs-utils: gssd - further shorten some pathnames
      nfs-utils: gssd - improve inotify
      nfs-utils: gssd - simplify handle_gssd_upcall


 support/include/nfslib.h    |    5 
 support/nfs/mydaemon.c      |   92 +++--
 utils/gssd/Makefile.am      |   24 +
 utils/gssd/gss_util.h       |    2 
 utils/gssd/gssd.c           |  785 +++++++++++++++++++++++++++++++++++++++++--
 utils/gssd/gssd.h           |   46 +--
 utils/gssd/gssd_main_loop.c |  263 --------------
 utils/gssd/gssd_proc.c      |  654 ++----------------------------------
 utils/gssd/svcgssd.c        |    8 
 utils/idmapd/idmapd.c       |    6 
 utils/statd/statd.c         |   66 +---
 11 files changed, 878 insertions(+), 1073 deletions(-)
 delete mode 100644 utils/gssd/gssd_main_loop.c

--
David Härdeman


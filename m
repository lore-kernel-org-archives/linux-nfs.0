Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:50791 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934292AbZHEOp6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2009 10:45:58 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] new statd [take 2]
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 05 Aug 2009 10:45:30 -0400
Message-ID: <20090805143550.12866.8377.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Apparently there is a 100KB per-email size limit imposed by
vger.kernel.org.  I've broken up the large statd patch, and
postponed the nfs(8) man page patches to another day.

Yesterday it was decided that:

  [PATCH 3/5] statd: change default state dir to /var/lib/nfs/statd

was overkill. That one has been dropped from this series.

The first two of the present patches introduce the .c files under
utils/new-statd/ .  The next patch adds actools infrastructure for
building the new statd and sm-notify executables.  The last patch
adds two new man pages for statd and sm-notify.

The old statd remains in utils/statd.  If sqlite3 and TI-RPC is
present on the build system, and TI-RPC is enabled during
configuration, the new statd is built and installed instead of the
old one.

See the description in the first patch for more details on the
features of the new implementation.

---

Chuck Lever (4):
      nfs-utils: introduce new statd implementation (4th part)
      nfs-utils: introduce new statd implementation (3rd part)
      nfs-utils: introduce new statd implementation (2nd part)
      nfs-utils: introduce new statd implementation (1st part)


 .gitignore                    |    4 
 Makefile.am                   |    4 
 aclocal/libcap.m4             |   15 +
 aclocal/libsqlite3.m4         |   33 ++
 aclocal/libtirpc.m4           |    2 
 configure.ac                  |   12 +
 utils/Makefile.am             |    7 
 utils/new-statd/Makefile.am   |  102 +++++
 utils/new-statd/file.c        |  779 ++++++++++++++++++++++++++++++++++++++
 utils/new-statd/hostname.c    |  520 +++++++++++++++++++++++++
 utils/new-statd/main.c        |  319 ++++++++++++++++
 utils/new-statd/nlmcall.c     |  525 ++++++++++++++++++++++++++
 utils/new-statd/sm-notify.c   |  155 ++++++++
 utils/new-statd/sm-notify.man |  286 ++++++++++++++
 utils/new-statd/sm_inter.x    |  107 +++++
 utils/new-statd/smncall.c     |  774 ++++++++++++++++++++++++++++++++++++++
 utils/new-statd/start-statd   |   12 +
 utils/new-statd/statd.h       |  135 +++++++
 utils/new-statd/statd.man     |  388 +++++++++++++++++++
 utils/new-statd/svc.c         |  841 +++++++++++++++++++++++++++++++++++++++++
 utils/statd/Makefile.am       |    9 
 21 files changed, 5024 insertions(+), 5 deletions(-)
 create mode 100644 aclocal/libcap.m4
 create mode 100644 aclocal/libsqlite3.m4
 create mode 100644 utils/new-statd/Makefile.am
 create mode 100644 utils/new-statd/file.c
 create mode 100644 utils/new-statd/hostname.c
 create mode 100644 utils/new-statd/main.c
 create mode 100644 utils/new-statd/nlmcall.c
 create mode 100644 utils/new-statd/sm-notify.c
 create mode 100644 utils/new-statd/sm-notify.man
 create mode 100644 utils/new-statd/sm_inter.x
 create mode 100644 utils/new-statd/smncall.c
 create mode 100644 utils/new-statd/start-statd
 create mode 100644 utils/new-statd/statd.h
 create mode 100644 utils/new-statd/statd.man
 create mode 100644 utils/new-statd/svc.c

-- 
Signature

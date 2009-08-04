From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] new statd [take 1]
Date: Tue, 04 Aug 2009 14:06:34 -0400
Message-ID: <20090804180334.21944.64404.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:56625 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933173AbZHDSHe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2009 14:07:34 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Here are some man page patches and the one big patch that adds the new
IPv6-capable statd.  I'd like to start socializing these changes to
expedite the new statd into mainline nfs-utils.

---

Chuck Lever (5):
      nfs(5): update nfs(5) with details about IPv6 support
      nfs-utils: introduce new statd implementation
      statd: change default state dir to /var/lib/nfs/statd
      nfs(5): Remove trailing blanks
      nfs(5): Add description of lookupcache mount option


 .gitignore                    |    4 
 Makefile.am                   |    4 
 aclocal/libcap.m4             |   15 +
 aclocal/libsqlite3.m4         |   33 ++
 aclocal/libtirpc.m4           |    2 
 configure.ac                  |   16 +
 utils/Makefile.am             |    7 
 utils/mount/nfs.man           |  377 ++++++++++++------
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
 utils/statd/sm-notify.man     |   12 -
 utils/statd/statd.man         |   10 
 24 files changed, 5282 insertions(+), 150 deletions(-)
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
Chuck Lever <chuck.lever@oracle.com>

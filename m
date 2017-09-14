Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33174 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751316AbdINOC1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Sep 2017 10:02:27 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C3E1480C05
        for <linux-nfs@vger.kernel.org>; Thu, 14 Sep 2017 14:02:27 +0000 (UTC)
Message-ID: <1505397745.3665.4.camel@redhat.com>
Subject: [PATCH 0/7] nfs-utils: Merge libnfsidmap tree with nfs-utils UPDATED
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Date: Thu, 14 Sep 2017 15:02:25 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It was suggested that merging the trees is more desirable than splitting
the common code out into a shared library, so this patch set attempts to
merge the libnfsidmap code into nfs-utils.

The main body of the code, copyright notices, and readme are copied
across, omitting the shared conffile code, and trimming unused files
like strlcpy.c and queue.h. The build files of both are adjusted to the
new structure, and the dependent nfs-utils now link to the included
shared library instead of an external one.

The source libnfsidmap tree did include some packaging files for
debian/dkpg which have been omitted, there are no packaging materials in
nfs-utils to merge them with, and i welcome advice on what should be
done here.

Change: libnfsidmap imported as support/nfsidmap/ 

Justin Mitchell (7):
  nfs-utils: const-ify the config handling functions
  nfs-utils: Merge conf_get_str and conf_get_section
  nfs-utils: Add get_str with default value
  nfs-utils: split conffile to a separate convenience lib
  nfs-utils: Import libnfsidmap codebase
  integrate libnfsidmap code with rest of nfs-utils
  nfs-utils: cleanup warnings from merged libnfsidmap code

 configure.ac                         |   50 +-
 support/Makefile.am                  |    8 +-
 support/include/conffile.h           |   23 +-
 support/nfs/Makefile.am              |   13 +-
 support/nfs/conffile.c               |   85 +--
 support/nfs/xlog.c                   |    2 +
 support/nfsidmap/AUTHORS             |    1 +
 support/nfsidmap/COPYING             |   30 +
 support/nfsidmap/Makefile.am         |   61 ++
 support/nfsidmap/README              |  126 ++++
 support/nfsidmap/gums.c              |  788 ++++++++++++++++++++
 support/nfsidmap/idmapd.conf         |  137 ++++
 support/nfsidmap/idmapd.conf.5       |  308 ++++++++
 support/nfsidmap/libnfsidmap.c       |  712 +++++++++++++++++++
 support/nfsidmap/libnfsidmap.pc.in   |   11 +
 support/nfsidmap/libtest.c           |  160 +++++
 support/nfsidmap/nfs4_uid_to_name.3  |  174 +++++
 support/nfsidmap/nfsidmap.h          |   67 ++
 support/nfsidmap/nfsidmap_internal.h |   79 +++
 support/nfsidmap/nss.c               |  468 ++++++++++++
 support/nfsidmap/static.c            |  413 +++++++++++
 support/nfsidmap/umich_ldap.c        | 1303 ++++++++++++++++++++++++++++++++++
 utils/Makefile.am                    |    2 -
 utils/blkmapd/Makefile.am            |    2 +-
 utils/exportfs/Makefile.am           |    2 +-
 utils/gssd/Makefile.am               |    7 +-
 utils/idmapd/Makefile.am             |    4 +-
 utils/mount/Makefile.am              |    2 +-
 utils/mountd/Makefile.am             |    2 +-
 utils/nfsd/Makefile.am               |    2 +-
 utils/nfsdcltrack/Makefile.am        |    2 +-
 utils/nfsidmap/Makefile.am           |    4 +-
 utils/statd/Makefile.am              |    4 +-
 33 files changed, 4973 insertions(+), 79 deletions(-)
 create mode 100644 support/nfsidmap/AUTHORS
 create mode 100644 support/nfsidmap/COPYING
 create mode 100644 support/nfsidmap/Makefile.am
 create mode 100644 support/nfsidmap/README
 create mode 100644 support/nfsidmap/gums.c
 create mode 100644 support/nfsidmap/idmapd.conf
 create mode 100644 support/nfsidmap/idmapd.conf.5
 create mode 100644 support/nfsidmap/libnfsidmap.c
 create mode 100644 support/nfsidmap/libnfsidmap.pc.in
 create mode 100644 support/nfsidmap/libtest.c
 create mode 100644 support/nfsidmap/nfs4_uid_to_name.3
 create mode 100644 support/nfsidmap/nfsidmap.h
 create mode 100644 support/nfsidmap/nfsidmap_internal.h
 create mode 100644 support/nfsidmap/nss.c
 create mode 100644 support/nfsidmap/static.c
 create mode 100644 support/nfsidmap/umich_ldap.c

-- 
1.8.3.1




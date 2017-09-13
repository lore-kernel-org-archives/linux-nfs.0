Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35482 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750999AbdIMN7G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 09:59:06 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id AD5F95D68A
        for <linux-nfs@vger.kernel.org>; Wed, 13 Sep 2017 13:59:06 +0000 (UTC)
Message-ID: <1505311126.15819.20.camel@redhat.com>
Subject: [PATCH 0/7] nfs-utils: Merge libnfsidmap tree with nfs-utils
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@redhat.com>
Date: Wed, 13 Sep 2017 14:58:46 +0100
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



Justin Mitchell (7):
  nfs-utils: const-ify the config handling functions
  nfs-utils: Merge conf_get_str and conf_get_section
  nfs-utils: Add get_str with default value
  nfs-utils: split conffile to a separate convenience lib
  nfs-utils: Import libnfsidmap codebase
  nfs-utils: integrate libnfsidmap code with rest of nfs-utils
  nfs-utils: cleanup warnings from merged libnfsidmap code

 configure.ac                          |   50 +-
 support/include/conffile.h            |   23 +-
 support/nfs/Makefile.am               |   13 +-
 support/nfs/conffile.c                |   85 +--
 support/nfs/xlog.c                    |    2 +
 utils/Makefile.am                     |    3 +-
 utils/blkmapd/Makefile.am             |    2 +-
 utils/exportfs/Makefile.am            |    2 +-
 utils/gssd/Makefile.am                |    7 +-
 utils/idmapd/Makefile.am              |    4 +-
 utils/libnfsidmap/AUTHORS             |    1 +
 utils/libnfsidmap/COPYING             |   30 +
 utils/libnfsidmap/Makefile.am         |   61 ++
 utils/libnfsidmap/README              |  126 ++++
 utils/libnfsidmap/gums.c              |  788 ++++++++++++++++++++
 utils/libnfsidmap/idmapd.conf         |  137 ++++
 utils/libnfsidmap/idmapd.conf.5       |  308 ++++++++
 utils/libnfsidmap/libnfsidmap.c       |  712 ++++++++++++++++++
 utils/libnfsidmap/libnfsidmap.pc.in   |   11 +
 utils/libnfsidmap/libtest.c           |  160 ++++
 utils/libnfsidmap/nfs4_uid_to_name.3  |  174 +++++
 utils/libnfsidmap/nfsidmap.h          |   67 ++
 utils/libnfsidmap/nfsidmap_internal.h |   79 ++
 utils/libnfsidmap/nss.c               |  468 ++++++++++++
 utils/libnfsidmap/static.c            |  413 +++++++++++
 utils/libnfsidmap/umich_ldap.c        | 1303 +++++++++++++++++++++++++++++++++
 utils/mount/Makefile.am               |    2 +-
 utils/mountd/Makefile.am              |    2 +-
 utils/nfsd/Makefile.am                |    2 +-
 utils/nfsdcltrack/Makefile.am         |    2 +-
 utils/nfsidmap/Makefile.am            |    4 +-
 utils/statd/Makefile.am               |    4 +-
 32 files changed, 4967 insertions(+), 78 deletions(-)
 create mode 100644 utils/libnfsidmap/AUTHORS
 create mode 100644 utils/libnfsidmap/COPYING
 create mode 100644 utils/libnfsidmap/Makefile.am
 create mode 100644 utils/libnfsidmap/README
 create mode 100644 utils/libnfsidmap/gums.c
 create mode 100644 utils/libnfsidmap/idmapd.conf
 create mode 100644 utils/libnfsidmap/idmapd.conf.5
 create mode 100644 utils/libnfsidmap/libnfsidmap.c
 create mode 100644 utils/libnfsidmap/libnfsidmap.pc.in
 create mode 100644 utils/libnfsidmap/libtest.c
 create mode 100644 utils/libnfsidmap/nfs4_uid_to_name.3
 create mode 100644 utils/libnfsidmap/nfsidmap.h
 create mode 100644 utils/libnfsidmap/nfsidmap_internal.h
 create mode 100644 utils/libnfsidmap/nss.c
 create mode 100644 utils/libnfsidmap/static.c
 create mode 100644 utils/libnfsidmap/umich_ldap.c

-- 
1.8.3.1



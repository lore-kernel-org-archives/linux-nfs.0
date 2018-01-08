Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34830 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750864AbeAHVtw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jan 2018 16:49:52 -0500
Received: by mail-io0-f193.google.com with SMTP id 14so16256847iou.2
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jan 2018 13:49:52 -0800 (PST)
Received: from manet.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 1sm7654959ion.51.2018.01.08.13.49.51
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 13:49:51 -0800 (PST)
Subject: [PATCH RFC 0/3] Add server-side support for junctions to nfs-utils
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 08 Jan 2018 16:49:50 -0500
Message-ID: <20180108213356.20133.54161.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

THIS IS AN UNTESTED RFC SERIES. I'm posting this for review only.

A while back I announced the deprecation of fedfs-utils. There were
a handful of components in fedfs-utils that we decided to keep. One
of those keepers was the "nfsref" command. (The other was autofs
support for /nfs4, which I hope Ian Kent is making progress on ;-)

This is an RFC patch series to introduce "nfsref" to nfs-utils,
minus the overhead of the LDAP / FedFS machinery. It also adds a
version of libnfsjunct which mountd can dynamically load to handle
non-FedFS junctions, replacing the same part from fedfs-utils.

I didn't apply a lot of brain cells to this port, so it's perhaps a
little larger than it needs to be. Still, it achieves a completely
LDAP-free implementation. I'm interested in comments about the
approach before I do more testing and refinement.

  ./configure --enable-junction --enable-caps

is needed before building.

Perhaps one thing that can be done is simply getting rid of the DLL
and building junction support into mountd. I'm not sure if a
transition period is necessary where the DLL is retained for a bit
until fedfs-utils is entirely gone. Does anything but mountd use
libnfsjunct ?


---

Chuck Lever (3):
      Add LDAP-free version of libjunction to nfs-utils
      Add LDAP-free version of libnfsjunct to nfs-utils
      Add 'nfsref' command


 aclocal/libxml2.m4                   |   15 
 configure.ac                         |   12 
 support/Makefile.am                  |    4 
 support/include/Makefile.am          |    3 
 support/include/fedfs_admin.h        |  342 +++++++
 support/include/junction.h           |  124 +++
 support/include/nfs-plugin.h         |  101 ++
 support/junction/Makefile.am         |   40 +
 support/junction/display.c           |  159 +++
 support/junction/export-cache.c      |  118 +++
 support/junction/junction-internal.h |  121 +++
 support/junction/junction.c          |  494 +++++++++++
 support/junction/locations.c         |  131 +++
 support/junction/nfs-plugin.c        |  350 ++++++++
 support/junction/nfs.c               | 1564 ++++++++++++++++++++++++++++++++++
 support/junction/path.c              |  345 ++++++++
 support/junction/xml.c               |  401 +++++++++
 utils/Makefile.am                    |    4 
 utils/nfsref/Makefile.am             |   39 +
 utils/nfsref/add.c                   |  271 ++++++
 utils/nfsref/lookup.c                |  211 +++++
 utils/nfsref/nfsref.c                |  188 ++++
 utils/nfsref/nfsref.h                |   47 +
 utils/nfsref/nfsref.man              |  180 ++++
 utils/nfsref/remove.c                |  145 +++
 25 files changed, 5409 insertions(+)
 create mode 100644 aclocal/libxml2.m4
 create mode 100644 support/include/fedfs_admin.h
 create mode 100644 support/include/junction.h
 create mode 100644 support/include/nfs-plugin.h
 create mode 100644 support/junction/Makefile.am
 create mode 100644 support/junction/display.c
 create mode 100644 support/junction/export-cache.c
 create mode 100644 support/junction/junction-internal.h
 create mode 100644 support/junction/junction.c
 create mode 100644 support/junction/locations.c
 create mode 100644 support/junction/nfs-plugin.c
 create mode 100644 support/junction/nfs.c
 create mode 100644 support/junction/path.c
 create mode 100644 support/junction/xml.c
 create mode 100644 utils/nfsref/Makefile.am
 create mode 100644 utils/nfsref/add.c
 create mode 100644 utils/nfsref/lookup.c
 create mode 100644 utils/nfsref/nfsref.c
 create mode 100644 utils/nfsref/nfsref.h
 create mode 100644 utils/nfsref/nfsref.man
 create mode 100644 utils/nfsref/remove.c

--
Chuck Lever

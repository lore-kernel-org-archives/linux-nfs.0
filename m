Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:45080 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752144AbeA1TCs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jan 2018 14:02:48 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH v3 0/3] NFS basic junction support for nfs-utils
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180128183357.3092.38903.stgit@manet.1015granger.net>
Date: Sun, 28 Jan 2018 11:02:43 -0800
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5B24119D-C39D-443F-BDD8-E97377F9C244@oracle.com>
References: <20180128183357.3092.38903.stgit@manet.1015granger.net>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

I suspect 1/3 is being rejected by vger because it is too large.
I will look for a way to break it up, and resend.


> On Jan 28, 2018, at 10:34 AM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
> Still UNTESTED.
>=20
> A while back I announced the deprecation of fedfs-utils. There were
> a handful of components in fedfs-utils that we decided to keep. One
> of those keepers was the "nfsref" command. (The other was autofs
> support for /nfs4, which I hope Ian Kent is making progress on ;-)
>=20
> This series introduces "nfsref" to nfs-utils, minus the overhead of
> the LDAP / FedFS machinery, and it builds support for NFS basic
> junctions into mountd, replacing the need to install a plug-in DLL
> from fedfs-utils.
>=20
> I didn't apply a lot of brain cells to this port, so it's perhaps a
> little larger than it needs to be. Still, it achieves a completely
> LDAP-free implementation that resides 100% in nfs-utils. I'm
> interested in comments about the approach before I do more testing
> and refinement.
>=20
> ./configure --enable-junction --enable-caps
>=20
> is needed before building.
>=20
>=20
> Changes since v2:
> None.
>=20
>=20
> Changes since RFC (v1):
> Patch 2/3 in the original series added the libnfsjunct.so DLL to
> nfs-utils. Series v2 instead replaces 2/3 with a patch that puts
> support for junctions into mountd without the need for a DLL.
>=20
> ---
>=20
> Chuck Lever (3):
>      Add LDAP-free version of libjunction to nfs-utils
>      mountd: Solder in support for NFS basic junctions
>      Add LDAP-free 'nfsref' command
>=20
>=20
> aclocal/libxml2.m4                   |   15=20
> configure.ac                         |   17=20
> support/Makefile.am                  |    4=20
> support/include/Makefile.am          |    2=20
> support/include/fedfs_admin.h        |  342 +++++++
> support/include/junction.h           |  124 +++
> support/junction/Makefile.am         |   34 +
> support/junction/display.c           |  159 +++
> support/junction/export-cache.c      |  118 +++
> support/junction/junction-internal.h |  121 +++
> support/junction/junction.c          |  494 +++++++++++
> support/junction/locations.c         |  131 +++
> support/junction/nfs.c               | 1564 =
++++++++++++++++++++++++++++++++++
> support/junction/path.c              |  345 ++++++++
> support/junction/xml.c               |  401 +++++++++
> utils/Makefile.am                    |    4=20
> utils/mountd/Makefile.am             |    8=20
> utils/mountd/cache.c                 |  189 ++--
> utils/nfsref/Makefile.am             |   39 +
> utils/nfsref/add.c                   |  271 ++++++
> utils/nfsref/lookup.c                |  211 +++++
> utils/nfsref/nfsref.c                |  188 ++++
> utils/nfsref/nfsref.h                |   47 +
> utils/nfsref/nfsref.man              |  180 ++++
> utils/nfsref/remove.c                |  145 +++
> 25 files changed, 5049 insertions(+), 104 deletions(-)
> create mode 100644 aclocal/libxml2.m4
> create mode 100644 support/include/fedfs_admin.h
> create mode 100644 support/include/junction.h
> create mode 100644 support/junction/Makefile.am
> create mode 100644 support/junction/display.c
> create mode 100644 support/junction/export-cache.c
> create mode 100644 support/junction/junction-internal.h
> create mode 100644 support/junction/junction.c
> create mode 100644 support/junction/locations.c
> create mode 100644 support/junction/nfs.c
> create mode 100644 support/junction/path.c
> create mode 100644 support/junction/xml.c
> create mode 100644 utils/nfsref/Makefile.am
> create mode 100644 utils/nfsref/add.c
> create mode 100644 utils/nfsref/lookup.c
> create mode 100644 utils/nfsref/nfsref.c
> create mode 100644 utils/nfsref/nfsref.h
> create mode 100644 utils/nfsref/nfsref.man
> create mode 100644 utils/nfsref/remove.c
>=20
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




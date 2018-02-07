Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42374 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754196AbeBGSuA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Feb 2018 13:50:00 -0500
Subject: Re: [PATCH v4 0/5] NFS basic junction support for nfs-utils
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
References: <20180129232527.10141.69789.stgit@manet.1015granger.net>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <ff522092-3c00-e50f-509e-d8a6bd6e0c62@RedHat.com>
Date: Wed, 7 Feb 2018 13:49:59 -0500
MIME-Version: 1.0
In-Reply-To: <20180129232527.10141.69789.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/29/2018 06:28 PM, Chuck Lever wrote:
> Still UNTESTED.
> 
> A while back I announced the deprecation of fedfs-utils. There were
> a handful of components in fedfs-utils that we decided to keep. One
> of those keepers was the "nfsref" command. (The other was autofs
> support for /nfs4, which I hope Ian Kent is making progress on ;-)
> 
> This series introduces "nfsref" to nfs-utils, minus the overhead of
> the LDAP / FedFS machinery, and it builds support for NFS basic
> junctions into mountd, replacing the need to install a plug-in DLL
> from fedfs-utils.
> 
> I didn't apply a lot of brain cells to this port, so it's perhaps a
> little larger than it needs to be. Still, it achieves a completely
> LDAP-free implementation that resides 100% in nfs-utils. I'm
> interested in comments about the approach before I do more testing
> and refinement.
> 
> ./configure --enable-junction --enable-caps
> 
> is needed before building.
The series was committed... thanks!

steved.

> 
> 
> Changes since v3:
> Broke up the first patch because it was apparently too large to
> be reflected through vger.kernel.org.
> 
> 
> Changes since v2:
> None.
> 
> 
> Changes since RFC (v1):
> Patch 2/3 in the original series added the libnfsjunct.so DLL to
> nfs-utils. Series v2 instead replaces 2/3 with a patch that puts
> support for junctions into mountd without the need for a DLL.
> 
> ---
> 
> Chuck Lever (5):
>       Add headers to support libjunction
>       Add infrastructure for libjunction
>       Add LDAP-free version of libjunction to nfs-utils
>       mountd: Solder in support for NFS basic junctions
>       Add LDAP-free 'nfsref' command
> 
> 
>  aclocal/libxml2.m4                   |   15 
>  configure.ac                         |   17 
>  support/Makefile.am                  |    4 
>  support/include/Makefile.am          |    2 
>  support/include/fedfs_admin.h        |  342 +++++++
>  support/include/junction.h           |  125 +++
>  support/junction/Makefile.am         |   34 +
>  support/junction/display.c           |  159 +++
>  support/junction/export-cache.c      |  118 +++
>  support/junction/junction-internal.h |  121 +++
>  support/junction/junction.c          |  494 +++++++++++
>  support/junction/locations.c         |  131 +++
>  support/junction/nfs.c               | 1564 ++++++++++++++++++++++++++++++++++
>  support/junction/path.c              |  345 ++++++++
>  support/junction/xml.c               |  401 +++++++++
>  utils/Makefile.am                    |    4 
>  utils/mountd/Makefile.am             |    8 
>  utils/mountd/cache.c                 |  189 ++--
>  utils/nfsref/Makefile.am             |   39 +
>  utils/nfsref/add.c                   |  271 ++++++
>  utils/nfsref/lookup.c                |  211 +++++
>  utils/nfsref/nfsref.c                |  188 ++++
>  utils/nfsref/nfsref.h                |   47 +
>  utils/nfsref/nfsref.man              |  180 ++++
>  utils/nfsref/remove.c                |  145 +++
>  25 files changed, 5050 insertions(+), 104 deletions(-)
>  create mode 100644 aclocal/libxml2.m4
>  create mode 100644 support/include/fedfs_admin.h
>  create mode 100644 support/include/junction.h
>  create mode 100644 support/junction/Makefile.am
>  create mode 100644 support/junction/display.c
>  create mode 100644 support/junction/export-cache.c
>  create mode 100644 support/junction/junction-internal.h
>  create mode 100644 support/junction/junction.c
>  create mode 100644 support/junction/locations.c
>  create mode 100644 support/junction/nfs.c
>  create mode 100644 support/junction/path.c
>  create mode 100644 support/junction/xml.c
>  create mode 100644 utils/nfsref/Makefile.am
>  create mode 100644 utils/nfsref/add.c
>  create mode 100644 utils/nfsref/lookup.c
>  create mode 100644 utils/nfsref/nfsref.c
>  create mode 100644 utils/nfsref/nfsref.h
>  create mode 100644 utils/nfsref/nfsref.man
>  create mode 100644 utils/nfsref/remove.c
> 
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

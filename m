Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37278 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933847AbeAITVB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Jan 2018 14:21:01 -0500
Date: Tue, 9 Jan 2018 14:21:00 -0500
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 0/3] Add server-side support for junctions to
 nfs-utils
Message-ID: <20180109192100.GB18087@fieldses.org>
References: <20180108213356.20133.54161.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180108213356.20133.54161.stgit@manet.1015granger.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for doing this!  I may not get the chance to do a real review,
but I'm in favor of the basic idea.

--b.

On Mon, Jan 08, 2018 at 04:49:50PM -0500, Chuck Lever wrote:
> THIS IS AN UNTESTED RFC SERIES. I'm posting this for review only.
> 
> A while back I announced the deprecation of fedfs-utils. There were
> a handful of components in fedfs-utils that we decided to keep. One
> of those keepers was the "nfsref" command. (The other was autofs
> support for /nfs4, which I hope Ian Kent is making progress on ;-)
> 
> This is an RFC patch series to introduce "nfsref" to nfs-utils,
> minus the overhead of the LDAP / FedFS machinery. It also adds a
> version of libnfsjunct which mountd can dynamically load to handle
> non-FedFS junctions, replacing the same part from fedfs-utils.
> 
> I didn't apply a lot of brain cells to this port, so it's perhaps a
> little larger than it needs to be. Still, it achieves a completely
> LDAP-free implementation. I'm interested in comments about the
> approach before I do more testing and refinement.
> 
>   ./configure --enable-junction --enable-caps
> 
> is needed before building.
> 
> Perhaps one thing that can be done is simply getting rid of the DLL
> and building junction support into mountd. I'm not sure if a
> transition period is necessary where the DLL is retained for a bit
> until fedfs-utils is entirely gone. Does anything but mountd use
> libnfsjunct ?
> 
> 
> ---
> 
> Chuck Lever (3):
>       Add LDAP-free version of libjunction to nfs-utils
>       Add LDAP-free version of libnfsjunct to nfs-utils
>       Add 'nfsref' command
> 
> 
>  aclocal/libxml2.m4                   |   15 
>  configure.ac                         |   12 
>  support/Makefile.am                  |    4 
>  support/include/Makefile.am          |    3 
>  support/include/fedfs_admin.h        |  342 +++++++
>  support/include/junction.h           |  124 +++
>  support/include/nfs-plugin.h         |  101 ++
>  support/junction/Makefile.am         |   40 +
>  support/junction/display.c           |  159 +++
>  support/junction/export-cache.c      |  118 +++
>  support/junction/junction-internal.h |  121 +++
>  support/junction/junction.c          |  494 +++++++++++
>  support/junction/locations.c         |  131 +++
>  support/junction/nfs-plugin.c        |  350 ++++++++
>  support/junction/nfs.c               | 1564 ++++++++++++++++++++++++++++++++++
>  support/junction/path.c              |  345 ++++++++
>  support/junction/xml.c               |  401 +++++++++
>  utils/Makefile.am                    |    4 
>  utils/nfsref/Makefile.am             |   39 +
>  utils/nfsref/add.c                   |  271 ++++++
>  utils/nfsref/lookup.c                |  211 +++++
>  utils/nfsref/nfsref.c                |  188 ++++
>  utils/nfsref/nfsref.h                |   47 +
>  utils/nfsref/nfsref.man              |  180 ++++
>  utils/nfsref/remove.c                |  145 +++
>  25 files changed, 5409 insertions(+)
>  create mode 100644 aclocal/libxml2.m4
>  create mode 100644 support/include/fedfs_admin.h
>  create mode 100644 support/include/junction.h
>  create mode 100644 support/include/nfs-plugin.h
>  create mode 100644 support/junction/Makefile.am
>  create mode 100644 support/junction/display.c
>  create mode 100644 support/junction/export-cache.c
>  create mode 100644 support/junction/junction-internal.h
>  create mode 100644 support/junction/junction.c
>  create mode 100644 support/junction/locations.c
>  create mode 100644 support/junction/nfs-plugin.c
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

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53160 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751123AbdIMP32 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 11:29:28 -0400
Date: Wed, 13 Sep 2017 11:29:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Justin Mitchell <jumitche@redhat.com>
Cc: Steve Dickson <steved@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Anibal Monsalve Salazar <anibal@debian.org>
Subject: Re: [PATCH 0/7] nfs-utils: Merge libnfsidmap tree with nfs-utils
Message-ID: <20170913152926.GC27431@parsley.fieldses.org>
References: <1505311126.15819.20.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1505311126.15819.20.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 13, 2017 at 02:58:46PM +0100, Justin Mitchell wrote:
> It was suggested that merging the trees is more desirable than splitting
> the common code out into a shared library, so this patch set attempts to
> merge the libnfsidmap code into nfs-utils.
> 
> The main body of the code, copyright notices, and readme are copied
> across, omitting the shared conffile code, and trimming unused files
> like strlcpy.c and queue.h. The build files of both are adjusted to the
> new structure, and the dependent nfs-utils now link to the included
> shared library instead of an external one.
> 
> The source libnfsidmap tree did include some packaging files for
> debian/dkpg which have been omitted, there are no packaging materials in
> nfs-utils to merge them with, and i welcome advice on what should be
> done here.

If I'm reading things right, Anibal Monsalve Salazar is the relevant
Debian maintainer (cc'd).

Traditionally I think Debian maintainers have prefered that upstream not
attempt Debian packaging at all, so I imagine they'll be OK with
ditching it.

--b.

> 
> 
> 
> Justin Mitchell (7):
>   nfs-utils: const-ify the config handling functions
>   nfs-utils: Merge conf_get_str and conf_get_section
>   nfs-utils: Add get_str with default value
>   nfs-utils: split conffile to a separate convenience lib
>   nfs-utils: Import libnfsidmap codebase
>   nfs-utils: integrate libnfsidmap code with rest of nfs-utils
>   nfs-utils: cleanup warnings from merged libnfsidmap code
> 
>  configure.ac                          |   50 +-
>  support/include/conffile.h            |   23 +-
>  support/nfs/Makefile.am               |   13 +-
>  support/nfs/conffile.c                |   85 +--
>  support/nfs/xlog.c                    |    2 +
>  utils/Makefile.am                     |    3 +-
>  utils/blkmapd/Makefile.am             |    2 +-
>  utils/exportfs/Makefile.am            |    2 +-
>  utils/gssd/Makefile.am                |    7 +-
>  utils/idmapd/Makefile.am              |    4 +-
>  utils/libnfsidmap/AUTHORS             |    1 +
>  utils/libnfsidmap/COPYING             |   30 +
>  utils/libnfsidmap/Makefile.am         |   61 ++
>  utils/libnfsidmap/README              |  126 ++++
>  utils/libnfsidmap/gums.c              |  788 ++++++++++++++++++++
>  utils/libnfsidmap/idmapd.conf         |  137 ++++
>  utils/libnfsidmap/idmapd.conf.5       |  308 ++++++++
>  utils/libnfsidmap/libnfsidmap.c       |  712 ++++++++++++++++++
>  utils/libnfsidmap/libnfsidmap.pc.in   |   11 +
>  utils/libnfsidmap/libtest.c           |  160 ++++
>  utils/libnfsidmap/nfs4_uid_to_name.3  |  174 +++++
>  utils/libnfsidmap/nfsidmap.h          |   67 ++
>  utils/libnfsidmap/nfsidmap_internal.h |   79 ++
>  utils/libnfsidmap/nss.c               |  468 ++++++++++++
>  utils/libnfsidmap/static.c            |  413 +++++++++++
>  utils/libnfsidmap/umich_ldap.c        | 1303 +++++++++++++++++++++++++++++++++
>  utils/mount/Makefile.am               |    2 +-
>  utils/mountd/Makefile.am              |    2 +-
>  utils/nfsd/Makefile.am                |    2 +-
>  utils/nfsdcltrack/Makefile.am         |    2 +-
>  utils/nfsidmap/Makefile.am            |    4 +-
>  utils/statd/Makefile.am               |    4 +-
>  32 files changed, 4967 insertions(+), 78 deletions(-)
>  create mode 100644 utils/libnfsidmap/AUTHORS
>  create mode 100644 utils/libnfsidmap/COPYING
>  create mode 100644 utils/libnfsidmap/Makefile.am
>  create mode 100644 utils/libnfsidmap/README
>  create mode 100644 utils/libnfsidmap/gums.c
>  create mode 100644 utils/libnfsidmap/idmapd.conf
>  create mode 100644 utils/libnfsidmap/idmapd.conf.5
>  create mode 100644 utils/libnfsidmap/libnfsidmap.c
>  create mode 100644 utils/libnfsidmap/libnfsidmap.pc.in
>  create mode 100644 utils/libnfsidmap/libtest.c
>  create mode 100644 utils/libnfsidmap/nfs4_uid_to_name.3
>  create mode 100644 utils/libnfsidmap/nfsidmap.h
>  create mode 100644 utils/libnfsidmap/nfsidmap_internal.h
>  create mode 100644 utils/libnfsidmap/nss.c
>  create mode 100644 utils/libnfsidmap/static.c
>  create mode 100644 utils/libnfsidmap/umich_ldap.c
> 
> -- 
> 1.8.3.1
> 
> 

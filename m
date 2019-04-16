Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFBBFC10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 16:46:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 850FB2087C
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 16:46:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726816AbfDPQqq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 12:46:46 -0400
Received: from fieldses.org ([173.255.197.46]:39302 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726647AbfDPQqq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Apr 2019 12:46:46 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id AD5BB3EB; Tue, 16 Apr 2019 12:46:45 -0400 (EDT)
Date:   Tue, 16 Apr 2019 12:46:45 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     steved@redhat.com, jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH RFC v3 0/8] restore nfsdcld
Message-ID: <20190416164645.GC3430@fieldses.org>
References: <20190326220730.3763-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326220730.3763-1-smayhew@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I've really only skimmed the changelogs and documentation and such, but
that all looks good to me, and I'm still expecting to commit the
kernel-side patches for 5.2, so I'm favor of these nfs-utils patches
instead, as long as they look good to Steve.

--b.

On Tue, Mar 26, 2019 at 06:07:22PM -0400, Scott Mayhew wrote:
> When nfsdcld was released, it was quickly deprecated in favor of the
> nfsdcltrack usermodehelper, so as to not require another running daemon.
> The nfsdcld code was removed from nfs-utils in 2012.  That prevents
> NFSv4 clients from reclaiming locks from nfsd's running in containers,
> since neither nfsdcltrack nor the legacy client tracking code work in
> containers.  These patches restore the nfsdcld code.
> 
> These patches are intended to go alongside some kernel patches that
> introduce an enhancement that allows nfsd to "slurp" up the client
> records during client tracking initialization and store them internally
> in hash table.  This enables nfsd to check whether an NFSv4 client is
> allowed to reclaim without having to do an upcall to nfsdcld.  It also
> allows nfsd to decide to end the v4 grace period early if the number of
> RECLAIM_COMPLETE operations it has received from "known" clients is
> equal to the number of entries in the hash table.  It also allows nfsd
> to skip the v4 grace period altogether if it knows there are no clients
> allowed to reclaim.
> 
> The new nfsdcld code will work with older kernels, however in that case
> there is no ability for nfsd to exit the grace period early or skip the
> grace period altogether.
> 
> v3:
> - removed PathExists restriction from the nfsdcld.service file
> - added the ability to do a one-time upgrade from older client tracking
>   methods (i.e. nfsdcltrack and/or the legacy v4recovery dir)
> v2:
> - Use sqlite3_column_int64() instead of sqlite3_column_int() to query
>   the current & recovery values from the grace table
> - Uncommented the nfsdcld section header in nfs.conf
> 
> Scott Mayhew (8):
>   Revert "nfsdcltrack: remove the nfsdcld daemon"
>   nfsdcld: move nfsdcld to its own directory
>   nfsdcld: a few enhancements
>   nfsdcld: remove some unused functions
>   nfsdcld: the -p option should specify the rpc_pipefs mountpoint
>   nfsdcld: add /etc/nfs.conf support
>   systemd: add a unit file for nfsdcld
>   nfsdcld: add a facility for migrating from older client tracking
>     methods
> 
>  .gitignore                   |    1 +
>  configure.ac                 |   23 +
>  nfs.conf                     |    4 +
>  support/include/cld.h        |    1 +
>  systemd/nfs-server.service   |    2 +
>  systemd/nfsdcld.service      |   10 +
>  utils/Makefile.am            |    4 +
>  utils/nfsdcld/Makefile.am    |   19 +
>  utils/nfsdcld/cld-internal.h |   33 +
>  utils/nfsdcld/legacy.c       |  180 ++++++
>  utils/nfsdcld/legacy.h       |   24 +
>  utils/nfsdcld/nfsdcld.c      |  774 ++++++++++++++++++++++++
>  utils/nfsdcld/nfsdcld.man    |  199 ++++++
>  utils/nfsdcld/sqlite.c       | 1109 ++++++++++++++++++++++++++++++++++
>  utils/nfsdcld/sqlite.h       |   35 ++
>  15 files changed, 2418 insertions(+)
>  create mode 100644 systemd/nfsdcld.service
>  create mode 100644 utils/nfsdcld/Makefile.am
>  create mode 100644 utils/nfsdcld/cld-internal.h
>  create mode 100644 utils/nfsdcld/legacy.c
>  create mode 100644 utils/nfsdcld/legacy.h
>  create mode 100644 utils/nfsdcld/nfsdcld.c
>  create mode 100644 utils/nfsdcld/nfsdcld.man
>  create mode 100644 utils/nfsdcld/sqlite.c
>  create mode 100644 utils/nfsdcld/sqlite.h
> 
> -- 
> 2.17.2

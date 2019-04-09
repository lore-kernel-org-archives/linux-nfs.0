Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D245C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 20:17:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CC58D2084F
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 20:17:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726517AbfDIURx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 16:17:53 -0400
Received: from fieldses.org ([173.255.197.46]:38260 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726496AbfDIURx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Apr 2019 16:17:53 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id CB4B81CEE; Tue,  9 Apr 2019 16:17:52 -0400 (EDT)
Date:   Tue, 9 Apr 2019 16:17:52 -0400
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/6] Make knfsd friendly to container uid/gid mapping
Message-ID: <20190409201752.GB29099@fieldses.org>
References: <20190409161342.34338-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190409161342.34338-1-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Apr 09, 2019 at 12:13:36PM -0400, Trond Myklebust wrote:
> The following patchset attempts to make knfsd more friendly to
> containers that are set up with container-level uid/gid mapping. The
> principles used are as follows:

Thanks!  Applied v2.--b.

> 
> - Assume upcalls for idmapping and RPCSEC_GSS should make use of the
>   user namespace of the idmapper/rpcsec_gss daemon, which can be
>   extracted from the cred used to open the upcall/downcall pseudo file.
> - Assume downcalls may use the current_user_ns(), since the process
>   context is that of the userland daemon that performs the downcall.
> - Assume that wire protocols are mapped with of the user namespace of
>   the process that started the knfsd server in the first place.
>   i.e. that AUTH_UNIX and possibly the SETATTR/GETATTR uids and gids
>   belong to the same user namespace as the process that started knfsd.
>   This should ensure that knfsd matches the behaviour of a generic
>   userspace NFS server running in the same circumstances.
> 
> ---
> v2: Temporary server sockets need to inherit the cred from their parent
> 
> Trond Myklebust (6):
>   SUNRPC: Cache the process user cred in the RPC server listener
>   SUNRPC: Temporary sockets should inherit the cred from their parent
>   lockd: Pass the user cred from knfsd when starting the lockd server
>   SUNRPC: Fix the server AUTH_UNIX userspace mappings
>   SUNRPC: rsi_parse() should use the current user namespace
>   nfsd: knfsd must use the container user namespace
> 
>  fs/lockd/clntlock.c               |  4 ++--
>  fs/lockd/svc.c                    | 29 +++++++++++++++++------------
>  fs/nfs/callback.c                 |  7 +++++--
>  fs/nfs/client.c                   |  1 +
>  fs/nfsd/export.c                  | 18 ++++++++++--------
>  fs/nfsd/nfs3xdr.c                 | 21 +++++++++++----------
>  fs/nfsd/nfs4idmap.c               |  8 ++++----
>  fs/nfsd/nfs4xdr.c                 |  5 +++--
>  fs/nfsd/nfsctl.c                  | 16 ++++++++--------
>  fs/nfsd/nfsd.h                    |  9 ++++++++-
>  fs/nfsd/nfssvc.c                  | 16 ++++++++--------
>  fs/nfsd/nfsxdr.c                  | 17 +++++++++--------
>  include/linux/lockd/bind.h        |  3 ++-
>  include/linux/sunrpc/svc_xprt.h   |  4 +++-
>  include/linux/sunrpc/svcsock.h    |  3 ++-
>  net/sunrpc/auth_gss/svcauth_gss.c |  6 +++---
>  net/sunrpc/svc_xprt.c             | 17 +++++++++++------
>  net/sunrpc/svcauth_unix.c         | 15 +++++++++------
>  net/sunrpc/svcsock.c              |  4 +++-
>  19 files changed, 119 insertions(+), 84 deletions(-)
> 
> -- 
> 2.20.1

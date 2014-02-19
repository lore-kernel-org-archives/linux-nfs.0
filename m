Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:39226 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbaBSOka convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Feb 2014 09:40:30 -0500
Received: by mail-ie0-f170.google.com with SMTP id rl12so282926iec.1
        for <linux-nfs@vger.kernel.org>; Wed, 19 Feb 2014 06:40:30 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [GIT PULL] Please pull NFS client fixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1392819180.3670.1.camel@leira.trondhjem.org>
Date: Wed, 19 Feb 2014 09:40:28 -0500
Cc: Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5B5733C1-4A37-4B3F-9B28-2CAA88C5C844@primarydata.com>
References: <1392819180.3670.1.camel@leira.trondhjem.org>
To: Torvalds Linus <torvalds@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 19, 2014, at 9:13, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Hi Linus,
> 
> The following changes since commit b28a960c42fcd9cfc987441fa6d1c1a471f0f9ed:
> 
>  Linux 3.14-rc2 (2014-02-09 18:15:47 -0800)
> 
> are available in the git repository at:
> 
>  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.14-4
> 
> for you to fetch changes up to 2564f0dc58962a08abc960fca820e344f61981ed:

Doh… The very last patch in the series was misapplied. I’ve fixed it up and pushed out a new tag using —force. It being 6:40 am in Oregon, hopefully you still haven’t applied the bad patch…

nfs-for-3.14-4 should now point to commit 146d70caaa1b87f64597743429d7da4b8073d0c9, which has Andy’s patch applied correctly.

Apologies…
  Trond

> 
>  NFS fix error return in nfs4_select_rw_stateid (2014-02-18 11:33:03 -0500)
> 
> ----------------------------------------------------------------
> NFS client bugfixes for Linux 3.14
> 
> Highlights include stable fixes for the following bugs:
> 
> - General performance regression due to NFS_INO_INVALID_LABEL being set
>  when the server doesn't support labeled NFS
> - Hang in the RPC code due to a socket out-of-buffer race
> - Infinite loop when trying to establish the NFSv4 lease
> - Use-after-free bug in the RPCSEC gss code.
> - nfs4_select_rw_stateid is returning with a non-zero error value on success
> 
> Other bug fixes:
> 
> - Potential memory scribble in the RPC bi-directional RPC code
> - Pipe version reference leak
> - Use the correct net namespace in the new NFSv4 migration code
> 
> ----------------------------------------------------------------
> Andy Adamson (1):
>      NFS fix error return in nfs4_select_rw_stateid
> 
> Trond Myklebust (7):
>      NFS: Do not set NFS_INO_INVALID_LABEL unless server supports labeled NFS
>      SUNRPC: Don't create a gss auth cache unless rpc.gssd is running
>      SUNRPC: Fix races in xs_nospace()
>      SUNRPC: Fix potential memory scribble in xprt_free_bc_request()
>      SUNRPC: Ensure that gss_auth isn't freed before its upcall messages
>      SUNRPC: Fix a pipe_version reference leak
>      NFSv4: Use the correct net namespace in nfs4_update_server
> 
> fs/nfs/inode.c                 | 14 ++++++++++----
> fs/nfs/internal.h              | 12 +++++++++++-
> fs/nfs/nfs4client.c            |  7 ++++---
> fs/nfs/nfs4namespace.c         | 12 ++++++------
> fs/nfs/nfs4state.c             |  1 +
> net/sunrpc/auth_gss/auth_gss.c | 19 ++++++++++++++++---
> net/sunrpc/backchannel_rqst.c  |  6 ++++--
> net/sunrpc/xprtsock.c          |  6 +++++-
> 8 files changed, 57 insertions(+), 20 deletions(-)
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> 

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


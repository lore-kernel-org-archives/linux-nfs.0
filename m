Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:36552 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754633Ab0IQQ0N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 12:26:13 -0400
Received: by yxp4 with SMTP id 4so788641yxp.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 09:26:13 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/22] Full NFSv2/v3 XDR overhaul series
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 17 Sep 2010 12:26:09 -0400
Message-ID: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond-

Here's the full XDR overhaul series.  Superfluous BUG_ON()'s have been
removed from both the NFSv2 and the NFSv3 components.

There may be some minor merge conflicts with Bryan's readdir changes
and with Jeff's async sillyrename patches.  I volunteer to take care
of those when you can set up a for-2.6.37 branch with everything you
have so far.

---

Chuck Lever (22):
      NFS: Fix hdrlen calculation in NFSv4's decode_read()
      lockd: Move nlmdbg_cookie2a() to svclock.c
      lockd: Introduce new-style XDR functions for NLMv4
      NFS: Move and update xdr_decode_foo() functions that we're keeping
      NFS: Remove unused old NFSv3 decoder functions
      NFS: Switch in new NFSv3 decoder functions
      NFS: Introduce new-style XDR decoding functions for NFSv2
      NFS: Move and update xdr_encode_foo() functions that we're keeping
      NFS: Remove unused old NFSv3 encoder functions
      NFS: Replace old NFSv3 encoder functions with xdr_stream-based ones
      NFS: Introduce new-style XDR encoding functions for NFSv3
      lockd: Introduce new-style XDR functions for NLMv3
      NFS: Move and update xdr_decode_foo() functions that we're keeping
      NFS: Replace old NFSv2 decoder functions with xdr_stream-based ones
      NFS: Introduce new-style XDR decoding functions for NFSv2
      NFS: Use the "nfs_stat" enum for nfs_stat_to_errno()'s argument
      NFS: Move and update xdr_encode_foo() functions that we're keeping
      NFS: Remove old NFSv2 encoder functions
      NFS: Introduce new-style XDR encoding functions for NFSv2
      SUNRPC: Refactor logic to NUL-terminate strings in pages
      SUNRPC: Correct an rpcbind debugging message
      NFS: Fix NFSv3 debugging messages in fs/nfs/nfs3proc.c


 fs/lockd/Makefile           |    6 
 fs/lockd/clnt4xdr.c         |  633 +++++++++
 fs/lockd/clntxdr.c          |  650 ++++++++++
 fs/lockd/svclock.c          |   30 
 fs/lockd/xdr.c              |  287 ----
 fs/lockd/xdr4.c             |  255 ----
 fs/nfs/internal.h           |    4 
 fs/nfs/nfs2xdr.c            | 1342 +++++++++++++-------
 fs/nfs/nfs3proc.c           |    5 
 fs/nfs/nfs3xdr.c            | 2929 ++++++++++++++++++++++++++++++++-----------
 fs/nfs/nfs4xdr.c            |    7 
 fs/nfs/proc.c               |    2 
 include/linux/lockd/debug.h |   10 
 include/linux/nfs3.h        |    3 
 include/linux/sunrpc/xdr.h  |    1 
 net/sunrpc/rpcb_clnt.c      |    5 
 net/sunrpc/xdr.c            |   17 
 17 files changed, 4403 insertions(+), 1783 deletions(-)
 create mode 100644 fs/lockd/clnt4xdr.c
 create mode 100644 fs/lockd/clntxdr.c

-- 
Chuck Lever

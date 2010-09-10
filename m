Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:65003 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624Ab0IJUIj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 16:08:39 -0400
Received: by yxp4 with SMTP id 4so1305439yxp.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 13:08:39 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/11] Overhaul NFSv2-related XDR functions
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 10 Sep 2010 16:08:36 -0400
Message-ID: <20100910200512.13321.55605.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond-

This patch series overhauls NFSv2 and NLMv3 XDR functions to
use the same strict buffer checking tools that the NFSv4 XDR
functions use.

I did some testing with OProfile and perf to see what kind of
CPU impact the additional checking has... didn't notice much
if any change on the workloads I tried (fsx and cthon).  I
was careful to structure the code (especially conditionals)
so that the common path was as short as possible.

---

Chuck Lever (11):
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


 fs/lockd/Makefile          |    4 
 fs/lockd/clntxdr.c         |  657 +++++++++++++++++++++
 fs/lockd/xdr.c             |  258 --------
 fs/nfs/internal.h          |    4 
 fs/nfs/nfs2xdr.c           | 1349 ++++++++++++++++++++++++++++++--------------
 fs/nfs/nfs3proc.c          |    5 
 fs/nfs/nfs3xdr.c           |    6 
 fs/nfs/nfs4xdr.c           |    5 
 fs/nfs/proc.c              |    2 
 include/linux/sunrpc/xdr.h |    1 
 net/sunrpc/rpcb_clnt.c     |    5 
 net/sunrpc/xdr.c           |   17 +
 12 files changed, 1598 insertions(+), 715 deletions(-)
 create mode 100644 fs/lockd/clntxdr.c

-- 
Chuck Lever

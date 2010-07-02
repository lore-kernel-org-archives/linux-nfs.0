Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51418 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759311Ab0GBRSd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jul 2010 13:18:33 -0400
Received: by iwn7 with SMTP id 7so3461836iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jul 2010 10:18:32 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/22] NFS v2 and v3 XDR overhaul
To: linux-nfs@vger.kernel.org
Date: Fri, 02 Jul 2010 13:18:30 -0400
Message-ID: <20100702165935.8761.88528.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Some light reading for the holiday weekend.

We'd like better protection against RPC buffer overflows due to bogus
server replies.  Also, for better CPU efficiency and a smaller
instruction cache footprint, we'd like to call all XDR encode/decode
functions with an xdr_stream already prepared by call_encode() and
call_decode(), rather than preparing it in every called XDR function.

Towards that end, I've rewritten the NFSv2, NLMv3, NFSv3, and NLMv4
XDR encoders and decoders to use xdr_streams.  Similar rewrites have
already been done for the kernel's rpcbind, MNT, and NSM XDR encoders
and decoders.

I've attempted to follow the style precedents set by Benny's recent
rewrite of the NFSv4 XDR encoders and decoders.

Testing via Oprofile and "perf top" shows that these routines weren't
a significant CPU user before these changes.  Afterwards, I don't see
much difference.  I checked CPU cycles, mispredicted branches, and bus
cycles.

These are also available in my cel-2.6.git repo on linux-nfs.org,
along with recent NFSROOT changes to use the mount option parsing
routines in fs/nfs/super.c.

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
      Fix NFSv3 debugging messages in fs/nfs/nfs3proc.c


 fs/lockd/Makefile           |    6 
 fs/lockd/clnt4xdr.c         |  640 +++++++++
 fs/lockd/clntxdr.c          |  657 ++++++++++
 fs/lockd/svclock.c          |   30 
 fs/lockd/xdr.c              |  287 ----
 fs/lockd/xdr4.c             |  255 ----
 fs/nfs/internal.h           |    4 
 fs/nfs/nfs2xdr.c            | 1350 +++++++++++++-------
 fs/nfs/nfs3proc.c           |    5 
 fs/nfs/nfs3xdr.c            | 2924 ++++++++++++++++++++++++++++++++-----------
 fs/nfs/nfs4xdr.c            |    7 
 fs/nfs/proc.c               |    2 
 include/linux/lockd/debug.h |   10 
 include/linux/nfs3.h        |    3 
 include/linux/sunrpc/xdr.h  |    1 
 net/sunrpc/rpcb_clnt.c      |    5 
 net/sunrpc/xdr.c            |   17 
 17 files changed, 4428 insertions(+), 1775 deletions(-)
 create mode 100644 fs/lockd/clnt4xdr.c
 create mode 100644 fs/lockd/clntxdr.c

-- 
Chuck Lever

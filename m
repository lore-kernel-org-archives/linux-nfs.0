Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56951 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758513Ab0KQRnd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 12:43:33 -0500
Received: by iwn35 with SMTP id 35so2371514iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 09:43:33 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/17] Update XDR functions for legacy NFS versions
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 12:43:28 -0500
Message-ID: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond-

As requested, here are my XDR updates for NFSv2 and v3, and NLM v3
and v4.  These are ported to 2.6.37-rc2.  I think they are ready for
linux-next and 2.6.38.

---

Chuck Lever (17):
      lockd: Introduce new-style XDR functions for NLMv4
      NFS: Move and update xdr_decode_foo() functions that we're keeping
      NFS: Remove unused old NFSv3 decoder functions
      NFS: Switch in new NFSv3 decoder functions
      NFS: Introduce new-style XDR decoding functions for NFSv2
      NFS: Update xdr_encode_foo() functions that we're keeping
      NFS: Remove unused old NFSv3 encoder functions
      NFS: Replace old NFSv3 encoder functions with xdr_stream-based ones
      NFS: Introduce new-style XDR encoding functions for NFSv3
      lockd: Introduce new-style XDR functions for NLMv3
      NFS: Move and update xdr_decode_foo() functions that we're keeping
      NFS: Replace old NFSv2 decoder functions with xdr_stream-based ones
      NFS: Introduce new-style XDR decoding functions for NFSv2
      NFS: Use the "nfs_stat" enum for nfs_stat_to_errno()'s argument
      NFS: Update xdr_encode_foo() functions that we're keeping
      NFS: Remove old NFSv2 encoder functions
      NFS: Introduce new-style XDR encoding functions for NFSv2


 fs/lockd/Makefile    |    6 
 fs/lockd/clnt4xdr.c  |  621 +++++++++++
 fs/lockd/clntxdr.c   |  643 +++++++++++
 fs/lockd/xdr.c       |  258 ----
 fs/lockd/xdr4.c      |  255 ----
 fs/nfs/internal.h    |    4 
 fs/nfs/nfs2xdr.c     | 1294 +++++++++++++++-------
 fs/nfs/nfs3xdr.c     | 2952 +++++++++++++++++++++++++++++++++++++-------------
 fs/nfs/proc.c        |    2 
 include/linux/nfs3.h |    3 
 10 files changed, 4320 insertions(+), 1718 deletions(-)
 create mode 100644 fs/lockd/clnt4xdr.c
 create mode 100644 fs/lockd/clntxdr.c

-- 
Chuck Lever

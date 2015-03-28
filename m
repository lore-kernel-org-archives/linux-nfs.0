Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34026 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbbC1Pqo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2015 11:46:44 -0400
Received: by pdbni2 with SMTP id ni2so127242874pdb.1
        for <linux-nfs@vger.kernel.org>; Sat, 28 Mar 2015 08:46:43 -0700 (PDT)
Message-ID: <5516CCDB.4020509@gmail.com>
Date: Sat, 28 Mar 2015 23:46:35 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 0/4] Define common macro NFS4_MAXTAGLEN for nfs/nfsd
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are four macro defines for max tag length, 
in fs/nfs/nfs4xdr.c,
/* NFSv4 COMPOUND tags are only wanted for debugging purposes */
#ifdef DEBUG
#define NFS4_MAXTAGLEN		20
#else
#define NFS4_MAXTAGLEN		0
#endif

in fs/nfs/callback_xdr.c,
#define CB_OP_TAGLEN_MAXSZ	(512)

in fs/nfsd/xdr4.h,
#define NFSD4_MAX_TAGLEN	128

in fs/nfsd/xdr4cb.h,
#define NFS4_MAXTAGLEN		20

But, according to rfc3530 and rfc5661, all the length should be
limited by opaque limited.

The patch site defines a common macro named NFS4_MAXTAGLEN for
all of them, limited to opaque limited.

Kinglong Mee (4):
  nfs: define NFS4_MAXTAGLEN to OPAQUE limits
  nfs: use NFS4_MAXTAGLEN for cb_taglen checking
  nfsd: use NFS4_MAXTAGLEN for nfsd taglen checking
  nfsd: use NFS4_MAXTAGLEN defined in include/linux/nfs4.h

 fs/nfs/callback_xdr.c | 5 ++---
 fs/nfs/nfs4xdr.c      | 7 -------
 fs/nfsd/nfs4xdr.c     | 2 +-
 fs/nfsd/xdr4.h        | 1 -
 fs/nfsd/xdr4cb.h      | 3 ++-
 include/linux/nfs4.h  | 1 +
 6 files changed, 6 insertions(+), 13 deletions(-)

-- 
2.3.4


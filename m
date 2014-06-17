Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:61494 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861AbaFQLoW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 07:44:22 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so9605547qcx.41
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jun 2014 04:44:21 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v2 0/4] nfsd: clean up sparse endianness warnings
Date: Tue, 17 Jun 2014 07:44:10 -0400
Message-Id: <1403005454-7319-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset does a number of cleanups to remove sparse warnings that
appear when -D__CHECK_ENDIAN__ is specified. Mostly, they just add
__force in the appropriate places to make it clear that casting directly
to a different endianness is intentional. I've also added comments to
clarify why we're doing this in the same places.

Note that there are still some sparse warnings that are not addressed.
This one looks like a bug in sparse to me. We're initializing different
slots in an array:

    fs/nfsd/nfssvc.c:120:10: warning: Initializer entry defined twice
    fs/nfsd/nfssvc.c:121:10:   also defined here

This warning is also not addressed in this set:

    fs/nfsd/auth.c:31:38: warning: incorrect type in argument 1 (different address spaces)
    fs/nfsd/auth.c:31:38:    expected struct cred const *cred
    fs/nfsd/auth.c:31:38:    got struct cred const [noderef] <asn:4>*real_cred

I think sparse is complaining that we're casting away __rcu when handling
creds. I'm not quite sure whether that's a real bug or not. I've left it alone
for now until I (or someone else) has some time to look more closely.

Jeff Layton (4):
  nfsd: add __force to opaque verifier field casts
  nfsd: clean up sparse endianness warnings in nfscache.c
  nfsd: nfsd_splice_read and nfsd_readv should return __be32
  nfsd: add appropriate __force directives to filehandle generation code

 fs/nfsd/nfs4proc.c  |  8 ++++++--
 fs/nfsd/nfs4state.c |  8 ++++++--
 fs/nfsd/nfscache.c  | 13 +++++++++++--
 fs/nfsd/nfsfh.c     |  9 ++++++++-
 fs/nfsd/nfsfh.h     | 15 +++++++++++----
 fs/nfsd/vfs.c       |  7 ++++---
 fs/nfsd/vfs.h       |  4 ++--
 7 files changed, 48 insertions(+), 16 deletions(-)

-- 
1.9.3


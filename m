Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37404 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbbFDQok (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 12:44:40 -0400
Received: by igbsb11 with SMTP id sb11so43803090igb.0
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 09:44:38 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Michael Skralivetsky <michael.skralivetsky@primarydata.com>
Subject: [PATCH 0/4] nfs: fix NFSv4.x client name generation problems
Date: Thu,  4 Jun 2015 12:44:25 -0400
Message-Id: <1433436269-12292-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Michael Skralivetsky reported some problems recently that turned out to
be client name string collisions. He has a test environment where the
hostnames are quite long, and only differ at the very end.

The v4.1 name string buffer is currently limited to 48 bytes, which is
very small. When we go to build the name string, the end can be
truncated and if the hostnames are long enough, this can allow the
client identifiers to be duplicates of one another.

This patchset should fix the problem by allowing the client name string
to be as long as the spec allows (1k). It also gets rid of the large-ish
on-stack buffers that are currently used to build these strings, and
fixes some potential memory reclaim recursion problems that could occur
when these strings are generated.

Jeff Layton (4):
  nfs: convert setclientid and exchange_id encoders to use
    clp->cl_owner_id
  nfs: update maxsz values for SETCLIENTID and EXCHANGE_ID
  nfs: make nfs4_init_nonuniform_client_string use a dynamically
    allocated buffer
  nfs: make nfs4_init_uniform_client_string use a dynamically allocated
    buffer

 fs/nfs/nfs4proc.c       | 159 ++++++++++++++++++++++++++++++++++--------------
 fs/nfs/nfs4xdr.c        |  11 ++--
 include/linux/nfs_xdr.h |   8 +--
 3 files changed, 121 insertions(+), 57 deletions(-)

-- 
2.4.2


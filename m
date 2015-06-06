Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:32882 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbbFFX1E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Jun 2015 19:27:04 -0400
Received: by iebgx4 with SMTP id gx4so78030668ieb.0
        for <linux-nfs@vger.kernel.org>; Sat, 06 Jun 2015 16:27:03 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Michael Skralivetsky <michael.skralivetsky@primarydata.com>,
        chuck.lever@oracle.com
Subject: [PATCH v2 0/4] nfs: fix NFSv4.x client name generation problems
Date: Sat,  6 Jun 2015 19:26:46 -0400
Message-Id: <1433633210-26110-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- improve patch description on fourth patch
- fix potential memory leak in uniform name string generation
- remove unneeded NULL cl_owner_id string check
- account for name blob length word in encode_setclientid_maxsz and
  encode_exchange_id_maxsz

Original patch description follows:

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

 fs/nfs/nfs4proc.c       | 156 ++++++++++++++++++++++++++++++++++--------------
 fs/nfs/nfs4xdr.c        |  14 +++--
 include/linux/nfs_xdr.h |   8 +--
 3 files changed, 121 insertions(+), 57 deletions(-)

-- 
2.4.2


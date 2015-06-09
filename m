Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:34154 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbbFIXoJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2015 19:44:09 -0400
Received: by iebmu5 with SMTP id mu5so23773391ieb.1
        for <linux-nfs@vger.kernel.org>; Tue, 09 Jun 2015 16:44:08 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Michael Skralivetsky <michael.skralivetsky@primarydata.com>,
        chuck.lever@oracle.com
Subject: [PATCH v3 0/5] nfs: fix NFSv4.x client name generation problems
Date: Tue,  9 Jun 2015 19:43:55 -0400
Message-Id: <1433893440-3988-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

This patchset is essentially the same as the v2 set, but prepends one
patch that just increases the size of the on-stack buffer for
EXCHANGE_ID, and marks that patch for stable.That should be enough
for a minimal fix for stable.

These patches and all of the others that I have queued for v4.2 are in
my nfs-4.2 branch here (which may be easier for cherry-picking):

    https://git.samba.org/?p=jlayton/linux.git;a=shortlog;h=refs/heads/nfs-4.2

v3:
- add preliminary patch that just increases the buffer in
  struct nfs41_exchange_id_args, and mark it for stable.
- no need to use GFP_NOFS to allocate cl_owner_id. That will now
  always be successfully allocated at mount time, and there is no
  potential for reclaim deadlock. Also add comments to explicitly
  spell this out.

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

Jeff Layton (5):
  nfs: increase size of EXCHANGE_ID name string buffer
  nfs: convert setclientid and exchange_id encoders to use
    clp->cl_owner_id
  nfs: update maxsz values for SETCLIENTID and EXCHANGE_ID
  nfs: make nfs4_init_nonuniform_client_string use a dynamically
    allocated buffer
  nfs: make nfs4_init_uniform_client_string use a dynamically allocated
    buffer

 fs/nfs/nfs4proc.c       | 171 +++++++++++++++++++++++++++++++++++-------------
 fs/nfs/nfs4xdr.c        |  14 ++--
 include/linux/nfs_xdr.h |   8 +--
 3 files changed, 136 insertions(+), 57 deletions(-)

-- 
2.4.2


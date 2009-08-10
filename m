Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34416 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753980AbZHJWJ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Aug 2009 18:09:27 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Subject: [PATCH 0/4] nfsd: add support for NFSv4 callbacks over IPv6 (try #3)
Date: Mon, 10 Aug 2009 18:09:13 -0400
Message-Id: <1249942157-12613-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Third attempt at a patchset to add support for NFSv4 callbacks over
IPv6. The main change here is that this set uses the standard routines
for address conversion that were recently added to the RPC layer in
Bruce's tree. Not only does this add IPv6 support but it's a net code
reduction.

There are also some other minor cleanups. The set should apply cleanly
to Bruce's tree as of earlier today.

Tested using opensolaris and linux clients and watching the traffic with
wireshark.

Jeff Layton (4):
  nfsd: convert nfs4_cb_conn struct to hold address in sockaddr_storage
  nfsd: make nfs4_client->cl_addr a struct sockaddr_storage
  nfsd: convert gen_callback to use rpc_uaddr2sockaddr
  nfsd: add support for NFSv4 callbacks over IPv6

 fs/nfsd/nfs4callback.c     |   11 +--
 fs/nfsd/nfs4state.c        |  176 ++++++++++++++++++++++----------------------
 include/linux/nfsd/state.h |    6 +-
 3 files changed, 93 insertions(+), 100 deletions(-)


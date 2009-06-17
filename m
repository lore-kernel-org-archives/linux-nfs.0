Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60751 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757808AbZFQSPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 14:15:48 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com, bfields@fieldses.org
Subject: [PATCH 0/4] nfsd: add support for NFSv4 callbacks over IPv6
Date: Wed, 17 Jun 2009 14:15:37 -0400
Message-Id: <1245262541-9362-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patchset is a first pass at adding IPv6 callback channel support
for knfsd. The set is fairly straightforward, but it does require a
number of changes to server side NFSv4 related structs that store
addresses in places that are only suitable for IPv4 addresses.

I've tested this by having Linux and OpenSolaris clients mount the
server over an IPv6 socket, get a delegation and ensure that the server
can recall that delegation. It all seems to work as expected. IPv4
callbacks also seem to continue to work correctly.

This patchset does change the some of the new 4.1 functions
(nfsd4_exchange_id in particular). Those changes are untested as of yet
but I'll see if I can do so if the approach in this set seems
reasonable.

Comments welcome...

Jeff Layton (4):
  nfsd: convert nfs4_callback struct to hold address in
    sockaddr_storage
  nfsd: break out setclientid port parsing into separate routine
  nfsd: make nfs4_client->cl_addr a struct sockaddr_storage
  nfsd: add support for NFSv4 callbacks over IPv6

 fs/nfsd/nfs4callback.c     |   11 +--
 fs/nfsd/nfs4state.c        |  220 ++++++++++++++++++++++++++++++++++++-------
 include/linux/nfsd/state.h |    6 +-
 3 files changed, 189 insertions(+), 48 deletions(-)


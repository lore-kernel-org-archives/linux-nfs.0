Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:44390 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030589Ab2CFP26 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2012 10:28:58 -0500
Received: by ghrr11 with SMTP id r11so2280207ghr.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Mar 2012 07:28:57 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, skinsbursky@parallels.com
Subject: [PATCH v9 0/6] nfsd: overhaul the client name tracking code
Date: Tue,  6 Mar 2012 10:28:47 -0500
Message-Id: <1331047733-1641-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the ninth iteration of this patchset. The primary motivation
for the respin here is to deal with the changes introduced by Stanislav's
"namespacification" of rpc_pipefs. I think this one should be closer
to what Stanislav suggested for this code.

In particular, I've done a bit more work to make this code
container-ready. One could consider this set as the opening salvo in the
effort to containerize nfsd. This one adds an initial per-namespace
nfsd_net object, and the info for the cld upcall is now stored within
that.

I have not attempted to do any work to containerize the legacy client
tracker. I envision us ripping that code out eventually as part of
the containerization effort. But we'll see...

Also, as requested by Bruce, I've broken out the patch to consolidate
the flags field and sent that yesterday in a patchset inappropriately
named:

    "nfsd: bugfixes for"

Mea culpa on that subject line, but this patchset depends on those
patches. I'd like to see these go in for 3.4 if possible.

Jeff Layton (6):
  nfsd: add nfsd4_client_tracking_ops struct and a way to set it
  sunrpc: create nfsd dir in rpc_pipefs
  nfsd: add a per-net-namespace struct for nfsd
  nfsd: add a header describing upcall to nfsdcld
  nfsd: add the infrastructure to handle the cld upcall
  nfsd: add notifier to handle mount/unmount of rpc_pipefs sb

 fs/nfsd/netns.h          |   35 +++
 fs/nfsd/nfs4recover.c    |  617 +++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4state.c      |   57 ++---
 fs/nfsd/nfsctl.c         |   22 ++-
 fs/nfsd/state.h          |   14 +-
 include/linux/nfsd/cld.h |   56 +++++
 net/sunrpc/rpc_pipe.c    |    5 +
 7 files changed, 750 insertions(+), 56 deletions(-)
 create mode 100644 fs/nfsd/netns.h
 create mode 100644 include/linux/nfsd/cld.h

-- 
1.7.7.6


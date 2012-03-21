Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42978 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333Ab2CUNwO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Mar 2012 09:52:14 -0400
Received: by ghrr11 with SMTP id r11so920975ghr.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Mar 2012 06:52:14 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v10 0/8] nfsd: overhaul the client name tracking code
Date: Wed, 21 Mar 2012 09:52:01 -0400
Message-Id: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the tenth iteration of this patchset. The primary motivation
of this respin is to fix up some merge conflicts with some fixes that
Bruce merged recently.

For those who haven't followed along on the last few iterations, this
patchset also begins the "containerization" of nfsd. It introduces a
per-ns object that I envision growing over time as we make more of the
nfsd code namespace aware.

I've also rolled in the patch to convert the cl_cb_flags to a generic
flags field since that's a prerequisite, and added a patch to ensure
that no one tries to use the legacy client tracking code in anything but
the init_net namespace.

I'd like to see this go into 3.4 if possible...

Thanks,

Jeff Layton (8):
  nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
  nfsd: add nfsd4_client_tracking_ops struct and a way to set it
  sunrpc: create nfsd dir in rpc_pipefs
  nfsd: add a per-net-namespace struct for nfsd
  nfsd: add a header describing upcall to nfsdcld
  nfsd: add the infrastructure to handle the cld upcall
  nfsd: add notifier to handle mount/unmount of rpc_pipefs sb
  nfsd: don't allow legacy client tracker init for anything but
    init_net

 fs/nfsd/netns.h          |   35 +++
 fs/nfsd/nfs4callback.c   |   14 +-
 fs/nfsd/nfs4proc.c       |    3 +-
 fs/nfsd/nfs4recover.c    |  636 +++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4state.c      |   74 +++---
 fs/nfsd/nfsctl.c         |   22 ++-
 fs/nfsd/state.h          |   26 ++-
 include/linux/nfsd/cld.h |   56 ++++
 net/sunrpc/rpc_pipe.c    |    5 +
 9 files changed, 796 insertions(+), 75 deletions(-)
 create mode 100644 fs/nfsd/netns.h
 create mode 100644 include/linux/nfsd/cld.h

-- 
1.7.7.6


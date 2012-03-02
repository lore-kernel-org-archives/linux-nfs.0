Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:51937 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756401Ab2CBUmg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 15:42:36 -0500
Received: by yhmm54 with SMTP id m54so1008975yhm.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Mar 2012 12:42:35 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, skinsbursky@parallels.com
Subject: [PATCH v8 0/6] nfsd: overhaul the client name tracking code
Date: Fri,  2 Mar 2012 15:42:24 -0500
Message-Id: <1330720950-5872-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the eighth iteration of this patchset. The primary motivation
for the respin here is to deal with the changes introduced by Stanislav's
"namespacification" of rpc_pipefs. I think this one should be closer
to what Stanislav suggested for this code.

In particular, I've tried to make the "helpers" be containerized
by net namespace already and simply have the code call those helpers
for init_net, and ignore cases where they get called for other net
namespaces.

An earlier version of this patchset can be viewed here. That set also
contains a more comprehensive description of the rationale for doing
this:

    http://www.spinics.net/lists/linux-nfs/msg26324.html

Jeff Layton (6):
  nfsd: add nfsd4_client_tracking_ops struct and a way to set it
  sunrpc: create nfsd dir in rpc_pipefs
  nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
  nfsd: add a header describing upcall to nfsdcld
  nfsd: add the infrastructure to handle the cld upcall
  nfsd: add notifier to handle mount/unmount of rpc_pipefs sb

 fs/nfsd/nfs4callback.c   |   14 +-
 fs/nfsd/nfs4proc.c       |    3 +-
 fs/nfsd/nfs4recover.c    |  594 ++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4state.c      |   50 ++---
 fs/nfsd/state.h          |   24 +-
 include/linux/nfsd/cld.h |   56 +++++
 net/sunrpc/rpc_pipe.c    |    5 +
 7 files changed, 683 insertions(+), 63 deletions(-)
 create mode 100644 include/linux/nfsd/cld.h

-- 
1.7.7.6


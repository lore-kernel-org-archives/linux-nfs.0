Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:61147 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013Ab2BMPPv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 10:15:51 -0500
Received: by qcqw6 with SMTP id w6so2987323qcq.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2012 07:15:51 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v6 0/5] nfsd: overhaul the client name tracking code
Date: Mon, 13 Feb 2012 10:15:40 -0500
Message-Id: <1329146145-7602-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the sixth iteration of this patchset. At this point, I've
decided just to focus on what's needed to replace the upcall for the
single-server case. It's possible that we'll need to revise the upcall
format later to handle clustered configurations, but until we know
specifically what we'll need, it's probably simpler not to worry about
it.

An earlier version of this patchset can be viewed here. That set also
contains a more comprehensive description of the rationale for this:

    http://www.spinics.net/lists/linux-nfs/msg26324.html

The main changes since the last set shouldn't require any changes to
the userspace code. Here are the highlights:

- nfsd4_grace_done has been renamed to nfsd4_record_grace_done

- most of the NULL pointer checks in the tracking ops wrappers have
  been removed. It's expected that each set of tracking ops will be
  complete.

- the clp->cl_firststate field has been removed and replaced with the
  NFSD4_CLIENT_STABLE and NFSD4_CLIENT_RECLAIM_COMPLETE cl_flags. This
  also fixes an existing bug in the v4.1 recovery code where a
  RECLAIM_COMPLETE call would return an error.

I'd like to see this considered for inclusion in 3.4.

Jeff Layton (5):
  nfsd: add nfsd4_client_tracking_ops struct and a way to set it
  sunrpc: create nfsd dir in rpc_pipefs
  nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
  nfsd: add a header describing upcall to nfsdcld
  nfsd: add the infrastructure to handle the cld upcall

 fs/nfsd/nfs4callback.c   |   14 +-
 fs/nfsd/nfs4proc.c       |    3 +-
 fs/nfsd/nfs4recover.c    |  498 ++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/nfs4state.c      |   50 ++---
 fs/nfsd/state.h          |   24 ++-
 include/linux/nfsd/cld.h |   56 +++++
 net/sunrpc/rpc_pipe.c    |    5 +
 7 files changed, 587 insertions(+), 63 deletions(-)
 create mode 100644 include/linux/nfsd/cld.h

-- 
1.7.7.6


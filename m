Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f46.google.com ([209.85.216.46]:61993 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543Ab2BAPoU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 10:44:20 -0500
Received: by qadc10 with SMTP id c10so3561743qad.19
        for <linux-nfs@vger.kernel.org>; Wed, 01 Feb 2012 07:44:19 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 0/5] nfsd: overhaul the client name tracking code
Date: Wed,  1 Feb 2012 10:44:07 -0500
Message-Id: <1328111052-28389-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the fifth iteration of this patchset. At this point, I've
decided just to focus on what's needed to replace the upcall for the
single-server case. It's possible that we'll need to revise the upcall
format later to handle clustered configurations, but until we know
specifically what we'll need, it's probably simpler not to worry about
it.

An earlier version of this patchset can be viewed here. That set also
contains a more comprehensive description of the rationale for this:

    http://www.spinics.net/lists/linux-nfs/msg26324.html

The main changes since the last are:

- the "remove" upcall has been put back. As Bruce rightly pointed out
  in review of the last set, it is necessary.

- the "init" upcall has been removed. For now, we'll just keep using
  get_seconds() everywhere. Until we have a clear need for upcalling
  to get a boot generation value, I'll keep the changes minimal.

- the upcall format has lost some fields in the union. Specifically,
  the cm_index and cm_generation value since they aren't used.

I'd like to see this considered for inclusion in 3.4.

Jeff Layton (5):
  nfsd: add nfsd4_client_tracking_ops struct and a way to set it
  sunrpc: create nfsd dir in rpc_pipefs
  nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
  nfsd: add a header describing upcall to nfsdcld
  nfsd: add the infrastructure to handle the cld upcall

 fs/nfsd/nfs4callback.c   |   12 +-
 fs/nfsd/nfs4recover.c    |  485 +++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4state.c      |   46 ++---
 fs/nfsd/state.h          |   22 ++-
 include/linux/nfsd/cld.h |   56 ++++++
 net/sunrpc/rpc_pipe.c    |    5 +
 6 files changed, 572 insertions(+), 54 deletions(-)
 create mode 100644 include/linux/nfsd/cld.h

-- 
1.7.7.6


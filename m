Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:35268 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965496Ab2B2RQD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Feb 2012 12:16:03 -0500
Received: by ggnh1 with SMTP id h1so3253662ggn.19
        for <linux-nfs@vger.kernel.org>; Wed, 29 Feb 2012 09:16:02 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, skinsbursky@parallels.com
Subject: [PATCH v7 0/5] nfsd: overhaul the client name tracking code
Date: Wed, 29 Feb 2012 12:15:52 -0500
Message-Id: <1330535757-24925-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the seventh iteration of this patchset. The primary motivation
for the respin here is to deal with the changes introduced by Stanislav's
"namespacification" of rpc_pipefs.

My conversion here is fairly simple-minded. Since most of the existing
nfsd code works under the aegis of "init_net", this patchset makes the
new code do basically the same thing.

I've not done any real work to make this do different pipes for different
namespaces or anything. As a result, the initialization of the client
tracking will currently fail if rpc_pipefs isn't mounted.

Comments or suggestions on this are welcome. I'm still trying to wrap
my brain around how all of this namespace stuff is supposed to work,
so it's quite possible I've overlooked something. In particular, I'd
like Stanislav's feedback since he's done the bulk of the rpc_pipefs
namespace work so far.

An earlier version of this patchset can be viewed here. That set also
contains a more comprehensive description of the rationale for doing
this:

    http://www.spinics.net/lists/linux-nfs/msg26324.html

Jeff Layton (5):
  nfsd: add nfsd4_client_tracking_ops struct and a way to set it
  sunrpc: create nfsd dir in rpc_pipefs
  nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
  nfsd: add a header describing upcall to nfsdcld
  nfsd: add the infrastructure to handle the cld upcall

 fs/nfsd/nfs4callback.c   |   14 +-
 fs/nfsd/nfs4proc.c       |    3 +-
 fs/nfsd/nfs4recover.c    |  515 ++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/nfs4state.c      |   50 ++---
 fs/nfsd/state.h          |   24 ++-
 include/linux/nfsd/cld.h |   56 +++++
 net/sunrpc/rpc_pipe.c    |    5 +
 7 files changed, 604 insertions(+), 63 deletions(-)
 create mode 100644 include/linux/nfsd/cld.h

-- 
1.7.7.6


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f46.google.com ([209.85.216.46]:65054 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803Ab2AWUBi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 15:01:38 -0500
Received: by qadc10 with SMTP id c10so2031128qad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 12:01:38 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Date: Mon, 23 Jan 2012 15:01:01 -0500
Message-Id: <1327348867-699-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the fourth iteration of this patchset. I had originally asked
Bruce to take the last one for 3.3, but decided at the last minute to
wait on it a bit. I knew there would be some changes needed in the
upcall, so by waiting we can avoid needing to deal with those in code
that has already shipped. I would like to see this patchset considered
for 3.4 however.

The previous patchset can be viewed here. That set also contains a
more comprehensive description of the rationale for this:

    http://www.spinics.net/lists/linux-nfs/msg26324.html

There have been a number of significant changes since the last set:

- the remove/expire upcall is now gone. In a clustered environment, the
records would need to be refcounted in order to handle that properly. That
becomes a sticky problem when you could have nodes rebooting. We don't
really need to remove these records individually however. Cleaning them
out only when the grace period ends should be sufficient.

- an "init" upcall has been added. When knfsd starts, it will upcall to
userspace for a boot_generation value. This will replace the boot time
in the scheme that generates clientid4's. By doing this, we eliminate
a potential problem with clientid4 collisions in clustered setups.

- a "client index" has been added to the create and check upcalls. The
kernel ignores this value for now, but eventually we'll need to use it
to help establish what clients own which locks in a clustered setup.

- a number of the client_tracking functions have been changed to void
return functions. Since the callers all ignore the return codes of those
functions, there was little benefit in passing them back.

Comments and suggestions are welcome...

Jeff Layton (6):
  nfsd: add nfsd4_client_tracking_ops struct and a way to set it
  sunrpc: create nfsd dir in rpc_pipefs
  nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
  nfsd: add a header describing upcall to nfsdcld
  nfsd: add the infrastructure to handle the cld upcall
  nfsd: get boot generation number from upcall instead of boot_time

 fs/nfsd/nfs4callback.c   |   12 +-
 fs/nfsd/nfs4recover.c    |  480 +++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4state.c      |   63 +++----
 fs/nfsd/state.h          |   22 ++-
 include/linux/nfsd/cld.h |   58 ++++++
 net/sunrpc/rpc_pipe.c    |    5 +
 6 files changed, 581 insertions(+), 59 deletions(-)
 create mode 100644 include/linux/nfsd/cld.h

-- 
1.7.7.5


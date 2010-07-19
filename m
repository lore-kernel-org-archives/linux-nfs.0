Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2423 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966728Ab0GSUut (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 16:50:49 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] nfsd: fix error handling in write_ports interfaces (resend)
Date: Mon, 19 Jul 2010 16:50:03 -0400
Message-Id: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Hi Bruce,

This patchset is a resend of the set I sent a month or so ago, with
a couple of other patches to fix related problems that came to light
as we were discussing them.

It's changed a bit from the original set by virtue of the fact that
patch #5 simplifies the lockd_up/down handling. Let me know if you
see any problems with the set and I'll work on addressing them.

Thanks,

Jeff Layton (5):
  nfsd: don't try to shut down nfs4 state handling unless it's up
  nfsd: fix error handling when starting nfsd with rpcbind down
  nfsd: fix error handling in __write_ports_addxprt
  nfsd: shut down NFSv4 state when nfsd_svc encounters an error
  nfsd: just keep single lockd reference for nfsd

 fs/nfsd/nfs4state.c |    2 ++
 fs/nfsd/nfsctl.c    |   20 ++++++++------------
 fs/nfsd/nfssvc.c    |   36 +++++++++++++++++-------------------
 3 files changed, 27 insertions(+), 31 deletions(-)


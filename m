Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865Ab0FGPgx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jun 2010 11:36:53 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] nfsd: fix error handling in write_ports interfaces
Date: Mon,  7 Jun 2010 11:33:17 -0400
Message-Id: <1275924800-5214-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patchset fixes some problems with refcounting when there are
problems starting up nfsd. The easiest way to reproduce this is to have
rpcbind down and then try to start nfsd. The write_ports calls will
generally return failure at that point due to the fact that lockd can't
register its ports. That leaves the nfsd_serv pointer set, with the
sv_threads count set at 0. The first two patches fix this problem.

The third patch, I'm not 100% sure on. It looks correct to me, but the
intent of the existing code is not very clear. I know this interface is
used by the rdma code, and I may be missing the point of doing it this
way. If the existing code is correct as-is, I'll plan to do a patch to
add some clarifying comments.

It also seems suspicious to me that __write_ports_addfd/delfd take and
put lockd references, but the addxprt/delxprt interfaces do not. If
someone were to addfd a socket and then delxprt it, it'll leave a lockd
reference dangling.

Should we be taking and putting lockd references in those codepaths as
well?

Jeff Layton (3):
  nfsd: don't try to shut down nfs4 state handling unless it's up
  nfsd: fix error handling when starting nfsd with rpcbind down
  nfsd: fix error handling in __write_ports_addxprt

 fs/nfsd/nfs4state.c |    2 ++
 fs/nfsd/nfsctl.c    |   18 ++++++++++++------
 2 files changed, 14 insertions(+), 6 deletions(-)


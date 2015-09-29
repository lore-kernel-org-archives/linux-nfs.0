Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:55301 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754226AbbI2U5h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Sep 2015 16:57:37 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [GIT PULL] Please pull an NFSoRDMA client bugfix
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Wise <swise@opengridcomputing.com>
Message-ID: <560AFB37.4080609@Netapp.com>
Date: Tue, 29 Sep 2015 16:57:27 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit d0f36c46deea97bd16b9277be2f1acac74d76037:

  xprtrdma: take HCA driver refcount at client (2015-08-05 16:22:56 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-for-4.3-2

for you to fetch changes up to 72c021738252dde5849d575a650239d6404930ee:

  xprtrdma: disconnect and flush cqs before freeing buffers (2015-09-28 10:42:35 -0400)

Thanks,
Anna

----------------------------------------------------------------
Steve Wise (1):
      xprtrdma: disconnect and flush cqs before freeing buffers

 net/sunrpc/xprtrdma/transport.c | 2 +-
 net/sunrpc/xprtrdma/verbs.c     | 9 ++++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

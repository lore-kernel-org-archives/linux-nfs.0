Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:17639 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777AbcGSU5e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jul 2016 16:57:34 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull one NFSoRDMA client cleanup
Message-ID: <0b20bf16-8ba7-b42f-25b2-29cd9d1a5e5e@Netapp.com>
Date: Tue, 19 Jul 2016 16:57:32 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit a4e187d83d88eeaba6252aac0a2ffe5eaa73a818:

  NFS: Don't drop CB requests with invalid principals (2016-07-11 15:50:43 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-4.8-2

for you to fetch changes up to 53d7852307295b4576777618cbc2684bb191fb46:

  xprtrdma: fix semicolon.cocci warnings (2016-07-19 16:56:12 -0400)

Thanks,
Anna

----------------------------------------------------------------
kbuild test robot (1):
      xprtrdma: fix semicolon.cocci warnings

 net/sunrpc/xprtrdma/verbs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

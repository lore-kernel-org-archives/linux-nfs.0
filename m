Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:46273 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808AbZKQEVT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2009 23:21:19 -0500
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Tue, 17 Nov 2009 15:21:23 +1100
Subject: [PATCH 0/2] Some fixes for NFS
Cc: linux-nfs@vger.kernel.org
Message-ID: <20091117042004.1563.95871.stgit@notabene.brown>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond,
 I have mentioned both of these patches to you before, but each time
 with a certain amount of indecisiveness.

 I am now quite confident of them and would like to submit them to
 you, possibly even for the next merge window.

Thanks,
NeilBrown


---

NeilBrown (2):
      NFS: honour preferred rsize/wsize reported by server.
      NFS4ERR_FILE_OPEN handling in Linux/NFS


 fs/nfs/nfs4proc.c |    5 +++++
 fs/nfs/nfs4xdr.c  |    1 +
 fs/nfs/super.c    |    4 ++--
 3 files changed, 8 insertions(+), 2 deletions(-)

-- 
Signature


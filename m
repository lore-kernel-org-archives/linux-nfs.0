Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:48478 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab1JYQRg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Oct 2011 12:17:36 -0400
Received: by ggnb1 with SMTP id b1so648280ggn.19
        for <linux-nfs@vger.kernel.org>; Tue, 25 Oct 2011 09:17:35 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] Three tiny clean-ups for 3.2 (repost)
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 25 Oct 2011 12:17:32 -0400
Message-ID: <20111025161631.5996.30680.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I found these nits on the wayward journey to implementing client-side
migration support.

---

Chuck Lever (3):
      NFS: Remove no-op less-than-zero checks on unsigned variables.
      NFS: Clean up nfs4_xdr_dec_secinfo()
      NFS: Fix documenting comment for nfs_create_request()


 fs/nfs/nfs4filelayout.c |    7 +++----
 fs/nfs/nfs4xdr.c        |    2 --
 fs/nfs/pagelist.c       |    2 +-
 3 files changed, 4 insertions(+), 7 deletions(-)

-- 
Chuck Lever

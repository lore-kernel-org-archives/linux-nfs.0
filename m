Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:63026 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab1IZP3t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 11:29:49 -0400
Received: by yib18 with SMTP id 18so4308853yib.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Sep 2011 08:29:48 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] Three tiny clean-ups for 3.2
To: linux-nfs@vger.kernel.org
Cc: bjschuma@netapp.com, andros@netapp.com
Date: Mon, 26 Sep 2011 11:29:46 -0400
Message-ID: <20110926152657.8595.6375.stgit@degas.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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

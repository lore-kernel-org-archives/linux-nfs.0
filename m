Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37258 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209Ab1H2StT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 14:49:19 -0400
Received: by iabu26 with SMTP id u26so731403iab.19
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2011 11:49:18 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] NFSD support for FedFS junctions
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 29 Aug 2011 14:48:39 -0400
Message-ID: <20110829184608.3305.93648.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce-

Sometime soon we are going to have working and easy-to-install FedFS
user space components.  These kernel patches are going to be needed
to make server-side FedFS support work.

Would you consider these for 3.2?

---

Trond Myklebust (3):
      NFSD: Add a cache for fs_locations information
      NFSD: Remove the ex_pathname field from struct svc_export
      NFSD: Cleanup for nfsd4_path()


 fs/nfsd/export.c            |   15 +-----
 fs/nfsd/nfs4xdr.c           |  106 ++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfsd.h              |    7 +++
 fs/nfsd/vfs.c               |   15 ++++++
 include/linux/nfsd/export.h |    2 -
 5 files changed, 103 insertions(+), 42 deletions(-)

-- 
Chuck Lever

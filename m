Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:55049 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755559Ab1ILXg7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 19:36:59 -0400
Received: by ywb5 with SMTP id 5so1248905ywb.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2011 16:36:59 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] NFSD support for FedFS junctions [v3]
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2011 19:36:56 -0400
Message-ID: <20110912232149.5080.95084.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sometime soon we are going to have easy-to-install user space FedFS
components.  Here are kernel patches needed to make server-side FedFS
support work.  Please consider these for the 3.2 kernel.

This respin addresses recent review comments.

Note that because NFSD previously didn't care about the execute bits
of junctions, neither does fedfs-utils-0.7.0 (released September 3,
2011).  Junctions created by this release and previous releases have
the sticky bit set, but the other mode bits are left untouched during
junction creation.

I will publish fedfs-utils-0.7.1 soon with a commit that makes new
junctions non-executable.

---

Trond Myklebust (3):
      NFSD: Add a cache for fs_locations information
      NFSD: Remove the ex_pathname field from struct svc_export
      NFSD: Cleanup for nfsd4_path()


 fs/nfsd/export.c            |   15 +-----
 fs/nfsd/nfs4xdr.c           |  106 ++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfsd.h              |    7 +++
 fs/nfsd/vfs.c               |   18 +++++++
 include/linux/nfsd/export.h |    2 -
 5 files changed, 106 insertions(+), 42 deletions(-)

-- 
Chuck Lever

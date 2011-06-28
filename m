Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:42041 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760382Ab1F1SZY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 14:25:24 -0400
Received: by iwn6 with SMTP id 6so374985iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 11:25:23 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Allow mounting exports that advertise NULL security
To: linux-nfs@vger.kernel.org
Date: Tue, 28 Jun 2011 14:25:20 -0400
Message-ID: <20110628181324.2866.98154.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The Linux NFS client fails to mount exports that advertise only
AUTH_NULL.  This small patch set, against 3.0-rc4, addresses the
problem, and corrects the behavior of the client when AUTH_NULL
appears anywhere in the returned authflavor list.

This behavioral requirement is not documented in any NFS protocol
specification.  Tom is considering some language for the active NFSv4
specifications to provide some guidance for client implementors on how
to interpret authflavor lists.

Eventually there should be a bugzilla filed against RHEL 6 by the
reporter.  When that happens, the bugzilla number should be documented
in the patch description of the second patch.

This problem has existed since at least 2.6.32.  This fix may be
appropriate for stable kernels.

---

Chuck Lever (2):
      NFS: Allow sec=none mounts in certain cases
      NFS: Clean up nfs_walk_authlist()


 fs/nfs/super.c |   54 +++++++++++++++++++++++++++++++-----------------------
 1 files changed, 31 insertions(+), 23 deletions(-)

-- 
Chuck Lever

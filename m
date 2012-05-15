Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:45341 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932855Ab2EOVmC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 17:42:02 -0400
Received: by yenm10 with SMTP id m10so70303yen.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 May 2012 14:42:01 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] NFSD patches for 3.5
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 15 May 2012 17:41:58 -0400
Message-ID: <20120515213808.1518.81260.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Here's the SETCLIENTID_CONFIRM fix from a couple of weeks ago, and a
separate clean-up patch.

I haven't been able to reproduce the other issue, where the server
hands out different clientid4's for the same nfs_client_id4 string.
The logic in nfsd4_setclientid() appears to be working as designed.

I may have mistaken the clientid4 verifier for the clientid4, but
I didn't save the original network capture, unfortunately.

---

Chuck Lever (2):
      NFSD: Use __be32 for variable holding return value
      NFSD: SETCLIENTID_CONFIRM returns NFS4ERR_CLID_INUSE too often


 fs/nfsd/nfs4state.c |   33 ++++++++++++---------------------
 1 files changed, 12 insertions(+), 21 deletions(-)

-- 
Chuck Lever

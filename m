Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:54825 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbaFITd1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2014 15:33:27 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/3] NFS: Fix SECINFO processing regression
Date: Mon, 9 Jun 2014 15:33:18 -0400
Message-ID: <1402342401-5640-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Iterate over multiple flavors returned by SECINFO. If RPC_AUTH_GSS is in the
secinfo list, fully test (get and auth, credential, and gss_context)

Fix some error paths.

Testing: Minimal testing of the nfs_test_gss_flavor. Will run more tests after
the June 2014 bakeathon

Note: Can supply a patch for SECINFO_NO_name to use nfs4_negotiate_security.

Andy Adamson (3):
  NFS check the return of nfs4_negotiate_security in nfs4_submount
  NFS Return -EPERM if no supported or matching SECINFO flavor
  NFS test SECINFO RPC_AUTH_GSS pseudoflavors for support

 fs/nfs/nfs4namespace.c | 66 +++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 55 insertions(+), 11 deletions(-)

-- 
1.8.3.1


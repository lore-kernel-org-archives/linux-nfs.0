Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f178.google.com ([209.85.214.178]:49693 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab3FGVgq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jun 2013 17:36:46 -0400
Received: by mail-ob0-f178.google.com with SMTP id fb19so7128411obc.23
        for <linux-nfs@vger.kernel.org>; Fri, 07 Jun 2013 14:36:45 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id l4sm762295obh.7.2013.06.07.14.36.44
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Jun 2013 14:36:45 -0700 (PDT)
Subject: [PATCH v2 0/2] Use root user credential for lease management
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 07 Jun 2013 17:36:43 -0400
Message-ID: <20130607213518.1127.72500.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

This series applies to post 3.10-rc4 kernels.  The idea is to make
newer kernels behave like 3.6 and previous when it comes to mounting
sec=krb5 when the client has no keytab available.

Take 2:
  - Don't use RPC_TASK_ROOTCREDS to generate the root cred

---

Chuck Lever (2):
      NFS: Never use user credentials for lease renewal
      NFS: Use root's credential for lease management when keytab is missing


 fs/nfs/nfs4proc.c  |    4 ++--
 fs/nfs/nfs4state.c |   20 +++++++++++++++++++-
 2 files changed, 21 insertions(+), 3 deletions(-)

-- 
Chuck Lever

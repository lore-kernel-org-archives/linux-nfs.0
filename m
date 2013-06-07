Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:33086 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754902Ab3FGTop (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jun 2013 15:44:45 -0400
Received: by mail-ye0-f174.google.com with SMTP id m10so996555yen.33
        for <linux-nfs@vger.kernel.org>; Fri, 07 Jun 2013 12:44:44 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id d91sm333019yhq.16.2013.06.07.12.44.43
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Jun 2013 12:44:43 -0700 (PDT)
Subject: [PATCH 0/3] Use root user credential for lease management
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 07 Jun 2013 15:44:42 -0400
Message-ID: <20130607194140.1296.54746.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

This series applies to post 3.10-rc4 kernels.  The idea is to make
newer kernels behave like 3.6 and previous when it comes to mounting
sec=krb5 when the client has no keytab available.

The third patch is similar to the 3.7 patch I posted a few days ago,
but is adjusted slightly to apply after the "Use krb5i for lease
management" patch that appears in 3.10-rc.

---

Chuck Lever (3):
      NFS: Never use user credentials for lease renewal
      NFS: Partially revert commit 845cbceb
      NFS: Use root's credential for lease management when keytab is missing


 fs/nfs/nfs4proc.c  |   25 ++++++++++++++++---------
 fs/nfs/nfs4state.c |   28 ++++++++++++++++++++--------
 2 files changed, 36 insertions(+), 17 deletions(-)

-- 
Chuck Lever

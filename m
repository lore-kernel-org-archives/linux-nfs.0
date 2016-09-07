Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37022 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbcIGT2F (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Sep 2016 15:28:05 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: [stable 4.7] xprtrdma: Create common scatterlist fields in rpcrdma_mw
Date: Wed, 7 Sep 2016 15:28:00 -0400
Message-Id: <EC53244E-DABF-48B9-BD5E-73D04E64C14C@oracle.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: stable@vger.kernel.org
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sending again. I have not received ACK/NAK after 1 week.

Please cherry-pick this commit for v4.7 stable:

commit 564471d2f2f1ddaf02119b8759813666db93abba
Author:     Chuck Lever <chuck.lever@oracle.com>
AuthorDate: Wed Jun 29 13:52:21 2016 -0400
Commit:     Anna Schumaker <Anna.Schumaker@Netapp.com>
CommitDate: Mon Jul 11 15:50:43 2016 -0400

   xprtrdma: Create common scatterlist fields in rpcrdma_mw


It addresses a bug in:

commit d7a21c1bed54adcf96e1713019a6ad87e90fbbc3
Author:     Chuck Lever <chuck.lever@oracle.com>
AuthorDate: Mon May 2 14:42:12 2016 -0400
Commit:     Anna Schumaker <Anna.Schumaker@Netapp.com>
CommitDate: Tue May 17 15:48:02 2016 -0400

   xprtrdma: Reset MRs in frwr_op_unmap_sync()

Which causes DMAR errors and an oops when using NFS/RDMA on
x86_64 systems where the iommu is enabled.

This was reported via IRC, I don't have the reporter's e-mail
address. I was able to reproduce the issue, and confirm that
564471d2f2f1 fixes the problem on v4.7.2.

(The actual fix is just two lines in that commit).

--
Chuck Lever




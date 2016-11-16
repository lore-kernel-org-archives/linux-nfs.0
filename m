Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43911 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936594AbcKPUvA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Nov 2016 15:51:00 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: [stable 4.8] xprtrdma: Fix DMAR failure in frwr_op_map() after reconnect
Date: Wed, 16 Nov 2016 15:50:47 -0500
Message-Id: <480AB524-3381-4699-B6E3-1D4D16FF843C@oracle.com>
Cc: Vasco Steinmetz <linux@kyberraum.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: stable@vger.kernel.org
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please cherry-pick this commit for v4.8 stable:

commit 62bdf94a2049822ef8c6d4b0e83cd9c3a1663ab4
Author:     Chuck Lever <chuck.lever@oracle.com>
AuthorDate: Mon Nov 7 16:16:24 2016 -0500
Commit:     Anna Schumaker <Anna.Schumaker@Netapp.com>
CommitDate: Thu Nov 10 11:04:54 2016 -0500

    xprtrdma: Fix DMAR failure in frwr_op_map() after reconnect

This commit is needed to prevent DMAR errors during a spurious
RDMA connection close. Problem reported by Vasco Steinmetz.

To apply 62bdf94a cleanly to v4.8.7, please first apply this
one-line clean-up commit:

commit 5690a22d8612e1788b48b4ea53c59868589cd2db
Author:     Daniel Wagner <daniel.wagner@bmw-carit.de>
AuthorDate: Fri Sep 23 10:41:57 2016 +0200
Commit:     Anna Schumaker <Anna.Schumaker@Netapp.com>
CommitDate: Fri Sep 23 09:48:24 2016 -0400

    xprtrdma: use complete() instead complete_all()


Thanks.

--
Chuck Lever


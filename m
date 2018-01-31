Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:39360 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752211AbeAaRd6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Jan 2018 12:33:58 -0500
Subject: [PATCH 0/2] Two short NFS/RDMA subjects
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 31 Jan 2018 12:33:56 -0500
Message-ID: <20180131173308.11367.93367.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Cavium has reported two issues for which I have fixes. These
should also go to stable.

---

Chuck Lever (2):
      xprtrdma: Fix calculation of ri_max_send_sges
      xprtrdma: Fix BUG after a device removal


 net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
 net/sunrpc/xprtrdma/verbs.c    |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

--
Chuck Lever

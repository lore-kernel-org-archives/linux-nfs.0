Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41332 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750907AbeFZX4Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Jun 2018 19:56:25 -0400
Received: from smtp.corp.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.27])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0C89C8553F
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jun 2018 23:56:25 +0000 (UTC)
Received: from f27-node1.dwysocha.net (dhcp145-42.rdu.redhat.com [10.13.145.42])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id CB3781C33F
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jun 2018 23:56:24 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 0/3] NFS: Fix output of mountstats for NFSv4 state opcodes such as SEQUENCE and RENEW
Date: Tue, 26 Jun 2018 19:56:20 -0400
Message-Id: <20180626235623.26898-1-dwysocha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series fixes the counts for NFSv4 state related opcodes such as SEQUENCE and RENEW.
Before this patch series, all of the iostats counts shown in /proc/self/mountstats are always 0.
This complicates troubleshooting so I am proposing a small change to the sunrpc interface to
print these stats.

The series renames an exported symbol in sunrpc, rpc_print_iostats, to rpc_clnt_show_stats,
as described in the header.

Dave Wysochanski (3):
  sunrpc: add _print_rpc_iostats() to output metrics for one RPC op
  sunrpc: Add _add_rpc_iostats() to add rpc_iostats metrics
  sunrpc: Change rpc_print_iostats to rpc_clnt_show_stats and handle
    rpc_clnt clones

 fs/nfs/super.c                 |  2 +-
 include/linux/sunrpc/metrics.h |  6 ++---
 net/sunrpc/stats.c             | 54 ++++++++++++++++++++++++++++++------------
 3 files changed, 43 insertions(+), 19 deletions(-)

-- 
2.14.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:37536 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1732299AbeGJS7s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Jul 2018 14:59:48 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9830A818F036
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jul 2018 18:59:26 +0000 (UTC)
Received: from f27-node1.dwysocha.net (dhcp145-42.rdu.redhat.com [10.13.145.42])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 903A52026D6B
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jul 2018 18:59:26 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] NFS: Fix output of mountstats for NFSv4 state opcodes such as SEQUENCE and RENEW
Date: Tue, 10 Jul 2018 14:59:22 -0400
Message-Id: <20180710185925.4047-1-dwysocha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series fixes the counts for NFSv4 lease and session related opcodes such as SEQUENCE
and RENEW.  Before this patch series, all of the iostats counts shown in /proc/self/mountstats
were always 0.  This complicates troubleshooting so I am proposing a small change to the sunrpc
interface to print these stats.

The series renames an exported symbol in sunrpc, rpc_print_iostats, to rpc_clnt_show_stats,
as described in the header.

As pointed out by Chuck Lever in the RFC patch, the output format remains the same so
this series does not change RPC_IOSTATS_VERS.  Along with this small change, the patch header
in the third patch is slightly changed to better explain the types of opcodes that are now properly
counted.

Dave Wysochanski (3):
  sunrpc: add _print_rpc_iostats() to output metrics for one RPC op
  sunrpc: Add _add_rpc_iostats() to add rpc_iostats metrics
  sunrpc: Change rpc_print_iostats to rpc_clnt_show_stats and handle
    rpc_clnt clones

 fs/nfs/super.c                 |  2 +-
 include/linux/sunrpc/metrics.h |  4 ++--
 net/sunrpc/stats.c             | 54 ++++++++++++++++++++++++++++++------------
 3 files changed, 42 insertions(+), 18 deletions(-)

-- 
2.14.3


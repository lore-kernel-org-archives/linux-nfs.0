Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34550 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbeCPOdl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2018 10:33:41 -0400
Received: by mail-io0-f193.google.com with SMTP id e7so12913845ioj.1
        for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2018 07:33:41 -0700 (PDT)
Subject: [PATCH 0/3] Trace point improvements for sunrpc
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 16 Mar 2018 10:33:39 -0400
Message-ID: <20180316142858.14289.44885.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi -

A clean-up and a couple of new trace point sites for client-side
sunrpc:

 - A trace point that reports the mountstats latency tuple, but
   for each RPC instead of average latency over many RPCs

 - A trace point that reports the result of RPC ping

Would you consider taking these for v4.17 ?

---

Chuck Lever (3):
      sunrpc: Simplify synopsis of some trace points
      sunrpc: Add static trace point to report RPC latency stats
      sunrpc: Add static trace point to report result of RPC ping


 include/trace/events/sunrpc.h |  106 ++++++++++++++++++++++++++++++++++-------
 net/sunrpc/clnt.c             |    8 +++
 net/sunrpc/sched.c            |   10 ++--
 net/sunrpc/stats.c            |   16 ++++--
 4 files changed, 110 insertions(+), 30 deletions(-)

--
Chuck Lever

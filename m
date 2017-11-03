Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:53465 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933455AbdKCRqA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Nov 2017 13:46:00 -0400
Received: by mail-io0-f196.google.com with SMTP id 189so7916044iow.10
        for <linux-nfs@vger.kernel.org>; Fri, 03 Nov 2017 10:46:00 -0700 (PDT)
Subject: [PATCH 0/2] Two fixes for RPC static trace points
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 03 Nov 2017 13:45:58 -0400
Message-ID: <20171103174509.31080.80937.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please consider this series for v4.15. Thanks!

---

Chuck Lever (2):
      sunrpc: Fix rpc_task_begin trace point
      sunrpc: Add rpc_request static trace point


 include/trace/events/sunrpc.h |   30 ++++++++++++++++++++++++++++++
 net/sunrpc/clnt.c             |    3 +--
 net/sunrpc/sched.c            |    3 +--
 3 files changed, 32 insertions(+), 4 deletions(-)

--
Chuck Lever

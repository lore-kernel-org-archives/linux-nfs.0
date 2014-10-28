Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:64860 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbaJ1SYW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2014 14:24:22 -0400
Received: by mail-qc0-f175.google.com with SMTP id b13so1160171qcw.34
        for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2014 11:24:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] sunrpc: new tracepoints for call/reply tracking
Date: Tue, 28 Oct 2014 14:24:11 -0400
Message-Id: <1414520654-1606-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add some tracepoints that I recently used when tracking
down the hang that Christoph reported recently. At this point, I still
haven't followed the trail to completion, but I think the problem is
not likely to be in the RPC code.

Please consider these for v3.19? Some of these are for client RPC and
some for server-side. I'll assume that Trond will merge these, but
review by others would be appreciated as well.

Jeff Layton (3):
  sunrpc: add some tracepoints in svc_rqst handling functions
  sunrpc: add new tracepoints in xprt handling code
  sunrpc: add tracepoints in xs_tcp_data_recv

 include/linux/sunrpc/xprtsock.h |  59 +++++++++++++++
 include/trace/events/sunrpc.h   | 160 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/svc.c                |  21 +++---
 net/sunrpc/svc_xprt.c           |  31 +++++---
 net/sunrpc/xprt.c               |   9 ++-
 net/sunrpc/xprtsock.c           |  69 +++--------------
 6 files changed, 269 insertions(+), 80 deletions(-)

-- 
1.9.3


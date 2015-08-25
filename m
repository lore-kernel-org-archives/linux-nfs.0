Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51782 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039AbbHYGEm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2015 02:04:42 -0400
From: Pratyush Anand <panand@redhat.com>
To: bfields@fieldses.org
Cc: rostedt@goodmis.org, linux-nfs@vger.kernel.org,
        Pratyush Anand <panand@redhat.com>
Subject: [PATCH 0/2] net: sunrpc: trace fixes
Date: Tue, 25 Aug 2015 11:34:18 +0530
Message-Id: <cover.1440482404.git.panand@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset fixes few bugs with sunrpc trace implementation.

Pratyush Anand (2):
  net: sunrpc: fix tracepoint Warning: unknown op '->'
  net: sunrpc: fix trace print of &xprt->xpt_remote

 include/trace/events/sunrpc.h | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

-- 
2.4.3


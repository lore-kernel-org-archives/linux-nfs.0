Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35092 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbcGNXDX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2016 19:03:23 -0400
Received: by mail-it0-f68.google.com with SMTP id f6so306769ith.2
        for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2016 16:03:23 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] Fix the socket autoclose regression
Date: Thu, 14 Jul 2016 19:02:59 -0400
Message-Id: <1468537380-66033-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steven

Does the following patch fix the issue you reported?

Cheers
  Trond

Trond Myklebust (1):
  SUNRPC: Force a close when a socket keepalive timeout occurs

 net/sunrpc/xprtsock.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

-- 
2.7.4


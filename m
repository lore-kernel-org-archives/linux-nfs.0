Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56232 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384Ab0JTPwo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Oct 2010 11:52:44 -0400
Received: by iwn7 with SMTP id 7so2427262iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 20 Oct 2010 08:52:44 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Two clean-ups for 2.6.37
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 20 Oct 2010 11:52:40 -0400
Message-ID: <20101020155158.6446.29915.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce-

Here are the clean-up patches we discussed.  Compile-tested only.

---

Chuck Lever (2):
      SUNRPC: Properly initialize sock_xprt.srcaddr in all cases
      SUNRPC: Use conventional switch statement when reclassifying sockets


 net/sunrpc/xprtsock.c |   43 +++++++++++++++++++++++++++++++++++++++----
 1 files changed, 39 insertions(+), 4 deletions(-)

-- 
Chuck Lever

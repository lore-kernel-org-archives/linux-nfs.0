From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] rpcb fixes
Date: Wed, 25 Jun 2008 17:24:15 -0400
Message-ID: <20080625212101.3171.86703.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62071 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbYFYVYm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2008 17:24:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

These patches implement some minor fixes to the kernel's rpcbind client.  They
are a prerequisite to more invasive patches.  The last two address issues we
uncovered at Connectathon 2008.

Please consider them for 2.6.27.

---

Chuck Lever (5):
      SUNRPC: Use only rpcbind v2 for AF_INET requests
      SUNRPC: Use GETADDR for rpcbind version 4 queries
      SUNRPC: Use rpcbind version 2 GETPORT
      SUNRPC: Document some naked integers in rpcbind client
      SUNRPC: More useful debugging output for rpcb client


 fs/Kconfig             |   21 -------------------
 net/sunrpc/rpcb_clnt.c |   54 +++++++++++++++++++++++++++++-------------------
 2 files changed, 33 insertions(+), 42 deletions(-)

-- 
Chuck Lever
chu ckl eve rat ora cle dot com

From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Fix-ups for 2.6.28 rpcb kernel support
Date: Mon, 15 Sep 2008 16:27:15 -0500
Message-ID: <20080915212437.3939.82594.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: okir@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:40089 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997AbYIOV1z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2008 17:27:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Here are a couple of fixes for the code that registers kernel RPC
services with the local rpcbind daemon.  The first is a patch that can
be merged with a patch you already have queued for 2.6.28.

---

Chuck Lever (2):
      SUNRPC: Use short-hand IPv6 ANYADDR for RPCB_SET
      SUNRPC: Register both netids for AF_INET6 servers


 net/sunrpc/rpcb_clnt.c |   12 +++-
 net/sunrpc/svc.c       |  143 ++++++++++++++++++++++++++++++++++--------------
 2 files changed, 108 insertions(+), 47 deletions(-)

-- 
Chuck Lever

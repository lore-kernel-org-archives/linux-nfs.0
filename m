From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] IPv6-related clean-ups
Date: Fri, 22 Aug 2008 12:41:53 -0400
Message-ID: <20080822163939.20488.92983.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:33582 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbYHVQmi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2008 12:42:38 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce, Trond -

This series introduces support for IPv6 in the NFSv4 callback server, and
cleans up parts of NLM before we start to introduce IPv6 support there.

Please consider these for 2.6.28.

(Whoops, looks like one more is coming in this series.  Expect a sixth
shortly).

---

Chuck Lever (5):
      lockd: Add address family-agnostic helper for zeroing the port number
      lockd: Specify address family for source address
      lockd: address-family independent printable addresses
      NLM: Clean up before introducing new debugging messages
      NFS: Enable NFSv4 callback server to listen on AF_INET6 sockets


 fs/lockd/host.c             |  118 ++++++++++++++++++++++++++++++++-----------
 fs/nfs/callback.c           |   11 ++--
 fs/nfs/callback.h           |    4 +
 fs/nfs/client.c             |    2 -
 include/linux/lockd/lockd.h |    4 +
 5 files changed, 101 insertions(+), 38 deletions(-)

-- 
Chuck Lever

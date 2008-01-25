From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 046/112] NFS: Clean up address comparison in
	__nfs_find_client()
Date: Fri, 25 Jan 2008 11:37:37 -0500
Message-ID: <20080125163737.31887.82909.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755581AbYAYRAB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:01 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxsek010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:00 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

The address comparison in the __nfs_find_client() function is deceptive.
It uses a memcmp() to check a pair of u32 fields for equality.  Not only is
this inefficient, but usually memcmp() is used for comparing two *whole*
sockaddr_in's (which includes comparisons of the address family and port
number), so it's easy to mistake the comparison here for a whole sockaddr
comparison, which it isn't.

So for clarity and efficiency, we replace the memcmp() with a simple test
for equality between the two s_addr fields.  This should have no
behavioral effect.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c3740f5..8b5f9b9 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -220,8 +220,7 @@ static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr, int
 		if (clp->cl_nfsversion != nfsversion)
 			continue;
 
-		if (memcmp(&clp->cl_addr.sin_addr, &addr->sin_addr,
-			   sizeof(clp->cl_addr.sin_addr)) != 0)
+		if (clp->cl_addr.sin_addr.s_addr != addr->sin_addr.s_addr)
 			continue;
 
 		if (!match_port || clp->cl_addr.sin_port == addr->sin_port)

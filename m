Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:39256 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756013AbaCSR3X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Mar 2014 13:29:23 -0400
Received: by mail-ig0-f182.google.com with SMTP id uy17so12389777igb.3
        for <linux-nfs@vger.kernel.org>; Wed, 19 Mar 2014 10:29:22 -0700 (PDT)
Message-ID: <1395250160.7168.1.camel@leira.trondhjem.org>
Subject: Re: [PATCH 1/2] SUNRPC: Ensure that call_connect times out correctly
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 19 Mar 2014 13:29:20 -0400
In-Reply-To: <5329CF7C.7090308@RedHat.com>
References: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com>
		 <53286A9D.2020007@RedHat.com>
		 <362845B0-35A4-4DDF-96F6-42582D66334B@primarydata.com>
		 <53288146.4010601@RedHat.com>
	 <1395168308.11244.3.camel@leira.trondhjem.org>
	 <532897DE.6060204@RedHat.com>
	 <EB317FC8-D521-4D80-98D7-FA48B0B9AF0C@primarydata.com>
	 <5329900C.3040200@RedHat.com>
	 <DAF0940D-107D-4251-B00A-DE829A31B36E@primarydata.com>
	 <5329A4B3.20601@RedHat.com>
	 <0C0E5EE2-E7BD-4BE3-961F-3B632B45F026@primarydata.com>
	 <5329CF7C.7090308@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2014-03-19 at 13:10 -0400, Steve Dickson wrote:
> 
> On 03/19/2014 11:04 AM, Trond Myklebust wrote:
> > IOW: there is no way to make mount.nfs honour the ‘retry’ and/or ‘bg' 
> > mount options in any consistent fashion by solely relying on kernel timeouts.
> I went back and took a look at how bg mounts worked in a number of
> older kernels f19(3.12) all the way back to RHEL6 kernel (2.6). 
> 
> I turns out you are right. The bg mounts were not depending on
> timeouts they were depended on the mount to fail with ECONNREFUSED
> The very first one, which is the reason the bg mount happen
> so fast... 
> 
> Its seems these days ECONNREFUSED are no longer return 
> as an error codes. They basically are turned into a 
> timeout... Just curious as to why ECONNREFUSED are 
> no longer returned?
> 
> Again, thanks for the cycles!

If the server is down during the initial rpc client creation, then I’d
still expect that to fail with ECONNREFUSED due to the rpc_ping() call.

Does the following patch help?


8<------------------------------------------------------------
>From dad628cc357a06cff8ce04300ba5c19bd92e73eb Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 19 Mar 2014 13:25:43 -0400
Subject: [PATCH] SUNRPC: Ensure call_status() deals correctly with SOFTCONN
 tasks

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index cea1308a6fda..ef96568902c5 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2004,6 +2004,10 @@ call_status(struct rpc_task *task)
 	case -EHOSTDOWN:
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
+		if (RPC_IS_SOFTCONN(task)) {
+			rpc_exit(task, status);
+			break;
+		}
 		/*
 		 * Delay any retries for 3 seconds, then handle as if it
 		 * were a timeout.
-- 
1.8.5.3


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com



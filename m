Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:37393 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753431Ab0BVVyi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2010 16:54:38 -0500
Received: from snoot.americas.sgi.com (case.americas.sgi.com [128.162.244.182])
	by relay1.corp.sgi.com (Postfix) with ESMTP id 061BB8F8052
	for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2010 13:54:38 -0800 (PST)
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by snoot.americas.sgi.com (Postfix) with ESMTP id 8E62749F2093
	for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2010 15:54:37 -0600 (CST)
Subject: [PATCH 0/2] knfsd: support larger numbers of clients
To: linux-nfs@vger.kernel.org
From: Ben Myers <bpm@sgi.com>
Date: Mon, 22 Feb 2010 15:54:37 -0600
Message-ID: <20100222215349.8481.80700.stgit@case>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Several customers that have large numbers of nfs clients have run afoul of the
existing connection limits ((nr_threads+3) * 20) and have been handling the
situation by bumping the number of nfsd threads.  There are two problems:

1) The maximum number of connections is tied to the number of nfsd threads.

The first patch decouples the maximum number of connections from the number of
threads by making it a tuneable.  Note that the default setting still uses the
existing formula.  Folks who want to handle additional connections without
bumping the number of threads can do so.

2) At around 1020 threads the send buffer size wraps negative and things grind
to a halt.

The second patch decouples the size of send and receive buffers from the number
of threads by making them tuneable.  Buffer sizes were getting absurdly large
as the number of nfsd threads grew.  Now they remain constant.


Both patches were originally implmented using sysctls but I have changed them
over to module parameters to match what Jeff Layton has done with
nlm_max_connections.

Thanks,
	Ben

---

Ben Myers (2):
      knfsd: nfsd_max_connections module parameter
      sunrpc: socket buffer size module parameter


 fs/nfsd/nfsctl.c         |    7 ++++
 fs/nfsd/nfssvc.c         |    3 ++
 net/sunrpc/sunrpc_syms.c |   39 ++++++++++++++++++++++
 net/sunrpc/svcsock.c     |   81 +++++++++++++++++++++++-----------------------
 4 files changed, 89 insertions(+), 41 deletions(-)

-- 

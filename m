Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59270 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752172AbcEXVQU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 May 2016 17:16:20 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/3] fix backchannel crash due to multipath
Date: Tue, 24 May 2016 17:16:13 -0400
Message-Id: <1464124576-27467-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

pynfs can crash the nfs server since the new multipath code.  The
problem is that pynfs uses the same tcp connection for multiple v4
clients (something the spec explicitly allows).  The callback client in
such cases has to share the same rpc_xprt.  The new rpc code, when it
creates two callback clients sharing the same rpc_xprt, ends up trying
to keep that rpc_xprt on the lists of two different rpc_xprt_switch's.
The first symptom I see is a list corruption warning.

So, I'm enforcing the requirement that there be only one backchannel
rpc_xprt_switch per tcp connection by doing as we do in the rpc_xprt
case: keeping a pointer to it in the svc_xprt, and using that when it's
available instead of allocating a new one.

That's a pretty straightforward fix (and I've verified it works), but
doesn't look very elegant.  If there's a better solution, I'm all ears.

--b.

J. Bruce Fields (3):
  SUNRPC: fix xprt leak on xps allocation failure
  nfsd4/rpc: move backchannel create logic into rpc code
  rpc: share one xps between all backchannels

 fs/nfsd/nfs4callback.c          | 18 +-----------------
 include/linux/sunrpc/clnt.h     |  2 --
 include/linux/sunrpc/svc_xprt.h |  1 +
 include/linux/sunrpc/xprt.h     |  1 +
 net/sunrpc/clnt.c               | 31 +++++++++++++++++++++++++------
 net/sunrpc/svc_xprt.c           |  2 ++
 net/sunrpc/xprtsock.c           |  1 +
 7 files changed, 31 insertions(+), 25 deletions(-)

-- 
2.5.5


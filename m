From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] RFC: backwards compatibility for TI-RPC
Date: Fri, 19 Dec 2008 10:31:25 -0500
Message-ID: <20081219152226.32332.5510.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: =okir@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:54977 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbYLSPlb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2008 10:41:31 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve, Olaf -

Normally I don't post a single patch with a cover letter, but this one
needs some 'splainin'.

I've tracked down a problem where rpc.statd in the latest nfs-utils
git repo breaks.  Even though rpc.statd hasn't changed yet, it is
now calling legacy RPC functions in TI-RPC rather than the original
Linux RPC implementation in glibc.  There appear to be some ABI
incompatibilities between the two.

I'd like to solicit comments on this approach of addressing this
problem.  And, more generally, also address the question of whether
we want to sponsor a more extensive effort to review our recently
adopted TI-RPC implementation to ensure that we have good ABI
compatibility with glibc's RPC implementation.  Should we consider
a strategy of merging these two implementations over time?

Talk amongst yourselves...

---

Chuck Lever (1):
      backwards compatibility: fix order of fields in TI-RPC's svc_req


 tirpc/rpc/svc.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:46167 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099Ab2HMVV0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 17:21:26 -0400
Received: by yhmm54 with SMTP id m54so3747749yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Aug 2012 14:21:25 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] (v2) rpcauth_create() returns -EEXIST
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Aug 2012 17:21:21 -0400
Message-ID: <20120813210739.1680.53741.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A few weeks ago I reported a problem with calling rpcauth_create()
in a loop to serially replace an RPC transport's with different
flavors.  When the loop gets up to the GSS flavors, the second
GSS flavor in the list can't be created.  rpcauth_create() fails
with -EEXIST.  See:

 http://marc.info/?t=134073471800002&r=1&w=2

rpcauth_create() invokes the rpc_auth ->create operation first then
releases the old rpc_auth.  But the old rpc_auth is holding onto
upcall pipes, which prevents the new GSS rpc_auth from creating its
own upcall pipes.

This breaks our client's SECINFO implementation, and will also break
UCS server trunking discovery when it appears.

Trond proposed a solution in the same e-mail thread, but it was
archived uuencoded.  Here is his suggestion in human-readable form:

> The solution here would be to create a per-rpc_client, per-pipename
> shared 'rpcsec_gss_pipe' object that holds the upcall pipe data.

This version of the patch series includes a couple of additional
clean-up patches, and proper Acked-by: lines.  I've confirmed that
the series addresses the issue, and thus should be ready to be
considered for merging.  (I tested on top of UCS patches, have not
tested with the SECINFO use case).

We may also want to consider applying the last three patches to 3.6
and 3.5-stable.

---

Chuck Lever (5):
      SUNRPC: Share upcall pipes among an rpc_clnt's rpc_auth objects
      SUNRPC: Insert a shim under gss_create()
      SUNRPC: Prepare gss_pipes_dentries_create() for sharing pipe data
      SUNRPC: Use __func__ in dprintk() in auth_gss.c
      SUNRPC: Clean up dprintk messages in rpc_pipe.c


 include/linux/sunrpc/clnt.h    |    1 
 net/sunrpc/auth_gss/auth_gss.c |  290 ++++++++++++++++++++++++++++++----------
 net/sunrpc/clnt.c              |    1 
 net/sunrpc/rpc_pipe.c          |    8 +
 4 files changed, 222 insertions(+), 78 deletions(-)

--
Chuck Lever

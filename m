Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:44553 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241Ab2HIVbL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 17:31:11 -0400
Received: by yhmm54 with SMTP id m54so1004938yhm.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Aug 2012 14:31:11 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] rpcauth_create() returns -EEXIST
To: linux-nfs@vger.kernel.org
Cc: skinsbursky@parallels.com
Date: Thu, 09 Aug 2012 17:31:08 -0400
Message-ID: <20120809205748.12984.88991.stgit@degas.1015granger.net>
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

Here's my crack at this idea.  This post is a request for comments;
more testing is needed.

---

Chuck Lever (3):
      SUNRPC: Share upcall pipes among an rpc_clnt's rpc_auth objects
      SUNRPC: Insert a shim under gss_create()
      SUNRPC: Prepare gss_pipes_dentries_create() for sharing pipe data


 include/linux/sunrpc/clnt.h    |    1 
 net/sunrpc/auth_gss/auth_gss.c |  232 ++++++++++++++++++++++++++++++++--------
 net/sunrpc/clnt.c              |    1 
 3 files changed, 189 insertions(+), 45 deletions(-)

-- 
Chuck Lever

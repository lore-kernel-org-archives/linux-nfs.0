Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:43585 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757841Ab2HJIRq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Aug 2012 04:17:46 -0400
Message-ID: <5024C3A1.7030908@parallels.com>
Date: Fri, 10 Aug 2012 12:17:37 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] rpcauth_create() returns -EEXIST
References: <20120809205748.12984.88991.stgit@degas.1015granger.net>
In-Reply-To: <20120809205748.12984.88991.stgit@degas.1015granger.net>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ack on all set.

10.08.2012 01:31, Chuck Lever пишет:
> A few weeks ago I reported a problem with calling rpcauth_create()
> in a loop to serially replace an RPC transport's with different
> flavors.  When the loop gets up to the GSS flavors, the second
> GSS flavor in the list can't be created.  rpcauth_create() fails
> with -EEXIST.  See:
>
>    http://marc.info/?t=134073471800002&r=1&w=2
>
> rpcauth_create() invokes the rpc_auth ->create operation first then
> releases the old rpc_auth.  But the old rpc_auth is holding onto
> upcall pipes, which prevents the new GSS rpc_auth from creating its
> own upcall pipes.
>
> This breaks our client's SECINFO implementation, and will also break
> UCS server trunking discovery when it appears.
>
> Trond proposed a solution in the same e-mail thread, but it was
> archived uuencoded.  Here is his suggestion in human-readable form:
>
>> The solution here would be to create a per-rpc_client, per-pipename
>> shared 'rpcsec_gss_pipe' object that holds the upcall pipe data.
>
> Here's my crack at this idea.  This post is a request for comments;
> more testing is needed.
>
> ---
>
> Chuck Lever (3):
>        SUNRPC: Share upcall pipes among an rpc_clnt's rpc_auth objects
>        SUNRPC: Insert a shim under gss_create()
>        SUNRPC: Prepare gss_pipes_dentries_create() for sharing pipe data
>
>
>   include/linux/sunrpc/clnt.h    |    1
>   net/sunrpc/auth_gss/auth_gss.c |  232 ++++++++++++++++++++++++++++++++--------
>   net/sunrpc/clnt.c              |    1
>   3 files changed, 189 insertions(+), 45 deletions(-)
>


-- 
Best regards,
Stanislav Kinsbursky

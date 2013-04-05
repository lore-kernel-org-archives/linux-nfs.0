Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:3755 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765747Ab3DEAos convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2013 20:44:48 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Subject: Re: [PATCH] NFSv4: Fix the fallback to AUTH_NULL if krb5i is not
 available
Date: Fri, 5 Apr 2013 00:44:44 +0000
Message-ID: <1365122684.3058.2.camel@leira.trondhjem.org>
References: <1365106659-7880-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1E8C59CD-F2C0-4C92-A06C-848F5C5AC5C0@oracle.com>
	 <1365108909.4101.6.camel@leira.trondhjem.org>
	 <4CCFB3B5-11EA-4648-AAD7-452D294C29DC@oracle.com>
In-Reply-To: <4CCFB3B5-11EA-4648-AAD7-452D294C29DC@oracle.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-04-04 at 16:34 -0700, Chuck Lever wrote:
> 
> On Apr 4, 2013, at 1:55 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > On Thu, 2013-04-04 at 13:29 -0700, Chuck Lever wrote:
> >> On Apr 4, 2013, at 1:17 PM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> >> 
> >>> If the rpcsec_gss_krb5 module cannot be loaded, the attempt to create
> >>> an rpc_client in nfs4_init_client will currently fail with an EINVAL.
> >>> Fix is to retry with AUTH_NULL.
> >>> 
> >>> Regression introduced by the commit "NFS: Use "krb5i" to establish NFSv4
> >>> state whenever possible"
> >>> 
> >>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> >>> Cc: Chuck Lever <chuck.lever@oracle.com>
> >>> Cc: Bryan Schumaker <bjschuma@netapp.com>
> >>> ---
> >>> fs/nfs/nfs4client.c | 2 ++
> >>> 1 file changed, 2 insertions(+)
> >>> 
> >>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> >>> index bb9789e..a4f2100 100644
> >>> --- a/fs/nfs/nfs4client.c
> >>> +++ b/fs/nfs/nfs4client.c
> >>> @@ -200,6 +200,8 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> >>> 
> >>>    __set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
> >>>    error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
> >> 
> >> The parameters passed to nfs_create_rpc_client() are all valid here, so -EINVAL is not a good error value in this situation.
> >> 
> >> rpcauth_create(), I think, should return -EACCES in this case, rather than -EINVAL.
> > 
> > I disagree. This isn't an issue of something being denied permission to
> > access a resource: it is that the flavour does not correspond to
> > anything in the kernel's list of valid auth flavours.
> > 
> > Either way, that is a separate issue that shouldn't affect this patch.
> 
> Fair enough.  -ENOENT might be a stronger choice in this case.  But yes, changing the API contract of rpcauth_auth() can be done later in an independent change.
> 
> However -EACCES is returned in some cases from the flavor's create method.  Instead of checking for -EINVAL in particular, how about retrying nfs_create_rpc_client() with AUTH_NULL if error < 0 ?

No. Why bother if the error is ECONNREFUSED. ENETUNREACH, or something
similar? The whole point of returning different errors is so that we can
distinguish between those cases that are worth retrying, and those that
are not.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

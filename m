From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: [GIT PULL] Please pull NFS client changes
Date: Tue, 18 May 2010 10:59:17 +0200
Message-ID: <20100518085917.GH14172@ics.muni.cz>
References: <1274135281.18654.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:39265 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754679Ab0ERI6j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 May 2010 04:58:39 -0400
In-Reply-To: <1274135281.18654.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Mon, May 17, 2010 at 06:28:01PM -0400, Trond Myklebust wrote:
> commit 9c7e7e23371e629dbb3b341610a418cdf1c19d91
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Thu May 13 12:51:06 2010 -0400
>=20
>     NFS: Don't call iput() in nfs_access_cache_shrinker
>    =20
>     iput() can potentially attempt to allocate memory, so we should a=
void
>     calling it in a memory shrinker. Instead, rely on the fact that i=
put() will
>     call nfs_access_zap_cache().
>    =20
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>=20
> commit 1a81bb8a1fa62ccb9b2411ac10ce702ca4ed302a
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Thu May 13 12:51:06 2010 -0400
>=20
>     NFS: Clean up nfs_access_zap_cache()
>    =20
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>=20
> commit 61d5eb2985b3b1d69fd53d7dc9789037c27f8d91
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Thu May 13 12:51:06 2010 -0400
>=20
>     NFS: Don't run nfs_access_cache_shrinker() when the mask is GFP_N=
OFS
>    =20
>     Both iput() and put_rpccred() might allocate memory under certain
>     circumstances, so make sure that we don't recurse and deadlock...
>    =20
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>=20
> commit 93a05e65c090dda9cbd79d0cf57b65c4dbd8da55
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Thu May 13 12:51:06 2010 -0400
>=20
>     SUNRPC: Ensure memory shrinker doesn't waste time in rpcauth_prun=
e_expired()
>    =20
>     The 'cred_unused' list, that is traversed by rpcauth_cache_shrink=
er is
>     ordered by time. If we hit a credential that is under the 60 seco=
nd garbage
>     collection moratorium, we should exit because we know at that poi=
nt that
>     all successive credentials are subject to the same moratorium...
>    =20
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>=20
> commit d300a41ef1c39cc5e6b90fd8834ea7ab16b5c48f
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Thu May 13 12:51:03 2010 -0400
>=20
>     SUNRPC: Dont run rpcauth_cache_shrinker() when gfp_mask is GFP_NO=
=46S
>    =20
>     Under some circumstances, put_rpccred() can end up allocating mem=
ory, so
>     check the gfp_mask to prevent deadlocks.
>    =20
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>=20
> commit 93870d76fee22e887aa6e7e1fc904dbeca976928
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Thu May 13 12:51:03 2010 -0400
>=20
>     NFS: Read requests can use GFP_KERNEL.
>    =20
>     There is no danger of deadlock should the allocation trigger page
>     writeback.
>    =20
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>=20
> commit 1f4c86c0be9064ab4eebd9e67c84606c1cfeec4b
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Thu May 13 12:51:02 2010 -0400
>=20
>     NFS: Don't use GFP_KERNEL in rpcsec_gss downcalls
>    =20
>     Again, we can deadlock if the memory reclaim triggers a writeback=
 that
>     requires a rpcsec_gss credential lookup.
>    =20
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>=20
> commit 8535b2be5181fc3019e4150567ef53210fe3b04f
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Thu May 13 12:51:01 2010 -0400
>=20
>     NFSv4: Don't use GFP_KERNEL allocations in state recovery
>    =20
>     We do not want to have the state recovery thread kick off and wai=
t for a
>     memory reclaim, since that may deadlock when the writebacks end u=
p
>     waiting for the state recovery thread to complete.
>    =20
>     The safe thing is therefore to use GFP_NOFS in all open, close,
>     delegation return, lock, etc. operations that may be called by th=
e
>     state recovery thread.
>    =20
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

do these solve also cases when rpc.gssd itself needs memory and there i=
s no
free memory because there is a lot of dirty pages as NFS cache?

rpc.gssd needs memory whenever it needs to create a new kerberos contex=
t (in
particular, fread needs it).

--=20
Luk=E1=B9 Hejtm=E1nek

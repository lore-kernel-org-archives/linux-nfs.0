Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:36372 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755847AbeASQPp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jan 2018 11:15:45 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] NFSD: hide unused svcxdr_dupstr()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180119145410.1096453-1-arnd@arndb.de>
Date: Fri, 19 Jan 2018 11:15:33 -0500
Cc: Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-Id: <894D5C4E-5AC6-4E77-A318-875433D0E45D@oracle.com>
References: <20180119145410.1096453-1-arnd@arndb.de>
To: Arnd Bergmann <arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jan 19, 2018, at 9:54 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>=20
> There is now only one caller left for svcxdr_dupstr() and this is =
inside
> of an #ifdef, so we can get a warning when the option is disabled:
>=20
> fs/nfsd/nfs4xdr.c:241:1: error: 'svcxdr_dupstr' defined but not used =
[-Werror=3Dunused-function]
>=20
> This adds another #ifdef around the definition.
>=20
> Fixes: e40d99e6183e ("NFSD: Clean up symlink argument XDR decoders")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Seems OK to me, and sorry for the noise.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> fs/nfsd/nfs4xdr.c | 2 ++
> 1 file changed, 2 insertions(+)
>=20
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index f51c9cccaf78..374a62af6034 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -237,6 +237,7 @@ svcxdr_tmpalloc(struct nfsd4_compoundargs *argp, =
u32 len)
>  * Note null-terminating in place usually isn't safe since the
>  * buffer might end on a page boundary.
>  */
> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> static char *
> svcxdr_dupstr(struct nfsd4_compoundargs *argp, void *buf, u32 len)
> {
> @@ -248,6 +249,7 @@ svcxdr_dupstr(struct nfsd4_compoundargs *argp, =
void *buf, u32 len)
> 	p[len] =3D '\0';
> 	return p;
> }
> +#endif
>=20
> /**
>  * savemem - duplicate a chunk of memory for later processing
> --=20
> 2.9.0
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




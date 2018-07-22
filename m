Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:43314 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727783AbeGVTKF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jul 2018 15:10:05 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] fs/nfsd: Delete invalid assignment statements in
 nfsd4_decode_exchange_id
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180722085044.50701-1-nixiaoming@huawei.com>
Date: Sun, 22 Jul 2018 14:12:20 -0400
Cc: Bruce Fields <bfields@fieldses.org>, jlayton@kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-Id: <2C39A9CD-4591-46C8-BB25-5FA2C85149CE@oracle.com>
References: <20180722085044.50701-1-nixiaoming@huawei.com>
To: nixiaoming <nixiaoming@huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jul 22, 2018, at 4:50 AM, nixiaoming <nixiaoming@huawei.com> wrote:
>=20
> dummy =3D be32_to_cpup(p++);
> dummy =3D be32_to_cpup(p++);
> Assigning value to "dummy" here, but that stored value
> is overwritten before it can be used.
>=20
> delete invalid assignment statements in nfsd4_decode_exchange_id
>=20
> Signed-off-by: n00202754 <nixiaoming@huawei.com>
> ---
> fs/nfsd/nfs4xdr.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index a96843c..8e78541 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1392,8 +1392,8 @@ nfsd4_decode_exchange_id(struct =
nfsd4_compoundargs *argp,
>=20
> 		/* ssp_window and ssp_num_gss_handles */
> 		READ_BUF(8);
> -		dummy =3D be32_to_cpup(p++);
> -		dummy =3D be32_to_cpup(p++);
> +		be32_to_cpup(p++);
> +		be32_to_cpup(p++);

If these values are not used, what's the point of byte swapping them?
Surely "p +=3D 2;" should be enough.


> 		break;
> 	default:
> 		goto xdr_error;

--
Chuck Lever




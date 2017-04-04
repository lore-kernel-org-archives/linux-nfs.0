Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36213 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752459AbdDDOWW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Apr 2017 10:22:22 -0400
Received: by mail-it0-f67.google.com with SMTP id a140so5087849ita.3
        for <linux-nfs@vger.kernel.org>; Tue, 04 Apr 2017 07:22:22 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v2] nfs: flexfilelayout: remove v3-only data server
 limitation
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <20170404131251.14212-1-tigran.mkrtchyan@desy.de>
Date: Tue, 4 Apr 2017 10:22:18 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <2D1373C0-69AF-4BF3-A484-F414C77B2412@monkey.org>
References: <20170404131251.14212-1-tigran.mkrtchyan@desy.de>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good to me! Thanks!

-dros

> On Apr 4, 2017, at 9:12 AM, Tigran Mkrtchyan =
<tigran.mkrtchyan@desy.de> wrote:
>=20
> Flexfilelayout supports data servers which talk NFS v3 and v4.{0,1,2}.
> However, this code path is disabled and v3 only servers are accepted.
> This change removes this limitation.
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
> fs/nfs/flexfilelayout/flexfilelayoutdev.c | 8 +++++++-
> 1 file changed, 7 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c =
b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
> index 457cfeb..aae05fc 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
> @@ -119,7 +119,13 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server =
*server, struct pnfs_device *pdev,
> 		if (ds_versions[i].wsize > NFS_MAX_FILE_IO_SIZE)
> 			ds_versions[i].wsize =3D NFS_MAX_FILE_IO_SIZE;
>=20
> -		if (ds_versions[i].version !=3D 3 || =
ds_versions[i].minor_version !=3D 0) {
> +		/*
> + 		 * check for valid major/minor combination.
> + 		 * currently we support dataserver which talk:
> + 		 *   v3, v4.0, v4.1, v4.2
> + 		 */
> +		if (!((ds_versions[i].version =3D=3D 3 && =
ds_versions[i].minor_version =3D=3D 0) ||
> +			(ds_versions[i].version =3D=3D 4 && =
ds_versions[i].minor_version < 3))) {
> 			dprintk("%s: [%d] unsupported ds version =
%d-%d\n", __func__,
> 				i, ds_versions[i].version,
> 				ds_versions[i].minor_version);
> --=20
> 2.9.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35234 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751188AbdHCCHa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Aug 2017 22:07:30 -0400
Received: by mail-io0-f194.google.com with SMTP id f1so349724ioj.2
        for <linux-nfs@vger.kernel.org>; Wed, 02 Aug 2017 19:07:30 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] nfs/flexfiles: fix leak of nfs4_ff_ds_version arrays
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <20170801202501.4876-1-dros@primarydata.com>
Date: Wed, 2 Aug 2017 22:07:28 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <A49F4A5C-4101-4D60-A14F-FC20D4F53897@monkey.org>
References: <20170801202501.4876-1-dros@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This should probably be CCed to some stable releases too. I'll figure it =
out soon.

-dros

> On Aug 1, 2017, at 4:25 PM, Weston Andros Adamson <dros@monkey.org> =
wrote:
>=20
> The client was freeing the nfs4_ff_layout_ds, but not the contained
> nfs4_ff_ds_version array.
>=20
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
> fs/nfs/flexfilelayout/flexfilelayoutdev.c | 1 +
> 1 file changed, 1 insertion(+)
>=20
> diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c =
b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
> index 6df7a0cf5660..f32c58bbe556 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
> @@ -32,6 +32,7 @@ void nfs4_ff_layout_free_deviceid(struct =
nfs4_ff_layout_ds *mirror_ds)
> {
> 	nfs4_print_deviceid(&mirror_ds->id_node.deviceid);
> 	nfs4_pnfs_ds_put(mirror_ds->ds);
> +	kfree(mirror_ds->ds_versions);
> 	kfree_rcu(mirror_ds, id_node.rcu);
> }
>=20
> --=20
> 2.11.0 (Apple Git-81)
>=20


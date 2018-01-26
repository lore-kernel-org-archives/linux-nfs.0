Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:58080 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751281AbeAZSXV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Jan 2018 13:23:21 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: problem on nfsd doing RDMA write
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyFX2aZPXy2NRiATwkbv8gDbyafB-4JsRUghuF84ih_WnQ@mail.gmail.com>
Date: Fri, 26 Jan 2018 10:23:10 -0800
Cc: Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0B3C835B-3E30-43F3-B53C-BFB4462543D3@oracle.com>
References: <CAN-5tyFX2aZPXy2NRiATwkbv8gDbyafB-4JsRUghuF84ih_WnQ@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jan 26, 2018, at 9:24 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> Hi Bruce/Chuck,
>=20
> There is a problem with nfsd doing a WRITE of size 4093,4094,4095. To
> reproduce, mount with RDMA and do a simple dd "dd if=3D/dev/zero
> of=3D/mnt/testfile bs=3D4093 count=3D1". What happens is that nfsd =
fails to
> parse GETATTR after the WRITE in the compound. It fails the operation
> with ERR_OP_ILLEGAL.
>=20
> The problem happens for the values where XDR round up ends up rounding
> up to the page size. I don't know if my fix is the appropriate way to
> fix this but with it I don't get the error:
>=20
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 2c61c6b..a8489c3 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1289,11 +1289,12 @@ static __be32 nfsd4_decode_opaque(struct =
nfsd4_compounda
>=20
>        len =3D XDR_QUADLEN(write->wr_buflen) << 2;
>        if (len >=3D avail) {
> -               int pages;
> +               int pages =3D 0;
>=20
>                len -=3D avail;
>=20
> -               pages =3D len >> PAGE_SHIFT;
> +               if (write->wr_buflen >=3D PAGE_SIZE)
> +                       pages =3D len >> PAGE_SHIFT;
>                argp->pagelist +=3D pages;
>                argp->pagelen -=3D pages * PAGE_SIZE;
>                len -=3D pages * PAGE_SIZE;
>=20
> So the problem is the using "len" instead of "write->wr_buflen" leads
> for the values 4093,4094,4095 that are rounded up to 4096, it makes
> pages=3D1 and the argp->pagelen ends up being a negative value leading
> to problems of parsing the GETATTR.

Would this also be a problem near any page boundary, say, a
write length of 8191 bytes?

Instead of using the rounded up "len", why not try this:

-		pages =3D len >> PAGE_SHIFT;
+		pages =3D write->wr_buflen >> PAGE_SHIFT;

And be sure to test with TCP as well.


> If this looks OK, I can send a patch.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




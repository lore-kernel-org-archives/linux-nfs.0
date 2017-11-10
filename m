Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40445 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755383AbdKJBr0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 20:47:26 -0500
From: NeilBrown <neilb@suse.com>
To: Joshua Watt <jpewhacker@gmail.com>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Fri, 10 Nov 2017 12:47:15 +1100
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: Re: [RFC 2/4] SUNRPC: Kill client tasks from debugfs
In-Reply-To: <20171108145942.5127-3-JPEWhacker@gmail.com>
References: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com> <20171108145942.5127-1-JPEWhacker@gmail.com> <20171108145942.5127-3-JPEWhacker@gmail.com>
Message-ID: <87lgjeewgs.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 08 2017, Joshua Watt wrote:

> The "kill" client entry in debugfs can be used to kill client tasks.
> Writing "0" causes only the currently pending tasks to be killed, while
> writing "1" all currently pending, and any future pending tasks to be
> killed.
>
> Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
> ---
>  net/sunrpc/debugfs.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++=
++
>  1 file changed, 48 insertions(+)
>
> diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
> index e980d2a493de..a2f33d168873 100644
> --- a/net/sunrpc/debugfs.c
> +++ b/net/sunrpc/debugfs.c
> @@ -118,6 +118,50 @@ static const struct file_operations tasks_fops =3D {
>  	.release	=3D tasks_release,
>  };
>=20=20
> +static int
> +kill_set(void *data, u64 val)
> +{
> +	struct rpc_clnt *clnt =3D data;
> +
> +	rpc_killall_tasks(clnt, (int)val);
> +	return 0;
> +}
> +
> +static int
> +kill_open(struct inode *inode, struct file *filp)
> +{
> +	int ret =3D simple_attr_open(inode, filp, NULL, kill_set, "%i");
> +
> +	if (!ret) {
> +		struct rpc_clnt *clnt =3D inode->i_private;
> +
> +		if (!atomic_inc_not_zero(&clnt->cl_count)) {
> +			simple_attr_release(inode, filp);
> +			ret =3D -EINVAL;
> +		}
> +	}
> +
> +	return ret;
> +}
> +
> +static int
> +kill_release(struct inode *inode, struct file *filp)
> +{
> +	struct rpc_clnt *clnt =3D inode->i_private;
> +
> +	rpc_release_client(clnt);
> +
> +	return simple_attr_release(inode, filp);
> +}
> +
> +static const struct file_operations kill_fops =3D {
> +	.owner	 =3D THIS_MODULE,
> +	.open	 =3D kill_open,
> +	.release =3D kill_release,
> +	.write	 =3D debugfs_attr_write,
> +	.llseek  =3D no_llseek,
> +};
> +
>  void
>  rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
>  {
> @@ -160,6 +204,10 @@ rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
>  	if (!debugfs_create_symlink("xprt", clnt->cl_debugfs, name))
>  		goto out_err;
>=20=20
> +	if (!debugfs_create_file("kill", S_IFREG | 0200, clnt->cl_debugfs,
> +				 clnt, &kill_fops))

S_IFREG is the default for debugfs_create_file, so it isn't needed.
There are about 1085 calls to debugfs_create_file() in the kernel of
which 85 specify S_IFREG.  Maybe we should fix them all...

And please use S_IWUSR rather than 0200.

I don't know if we really need this functionality if debugfs, but I
guess that is why we are putting it there - to see.

Thanks,
NeilBrown


> +		goto out_err;
> +
>  	return;
>  out_err:
>  	debugfs_remove_recursive(clnt->cl_debugfs);
> --=20
> 2.13.6

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloFBSUACgkQOeye3VZi
gbmK/w/6Aipgp9f3l9niduonv/ib9nF1tPkIc/EtdASWMWC8ZtiJYeauEaEsxu8Y
hypwYEr3tBC/YMjQZvw5tisag07fk6YS3AQGGOhhG7uYtA2ZvEsvxYzKa1uyy/10
EPn2nkwkt9pllI0lnYCDKrWGmRjTM2UPH2fY6aNze/iUD4OTNfg9k23G120IElYf
0Pyh1XAZ61OnhUF5jOXqccoV/kmU5R1UC0VEgqKt/qY+FTFkoGmjXwCd3qH68qUq
Zouaj+FOGiSeTbRZSKbjnt9kUQ1+aa6orLFNCe96B4zMKcfj9pVqPj0HAmlgNuUi
KXdEgBPluQLEmUp/dTW/qjGNe6XS8vBN81gwsc8HRbkdtkKZxK97H+OWlYOap9So
1KZCXXckQr39JsMRTwQDB1n0D/lAhiuWyANufaaGfwTpp5Qwd7QBBSPQVYNrLUdD
2ooGrPp77Rr43DZkc4ziSOowSEYMgnWRuAcn+eqc+rqP5OhcE5xAFAIT0ed028ch
j8YpFTYhNamdiickHwjulhf7IshqfKZMVFe46SJ2ZoL/gej9EO3X2wxjXira9xAV
Ew9400fYbtNUx0lgLFOF6AUkiwqLbFM7n0SOQBTX487b9HOPImFVG113TCCs1RnD
0BnYhcMy5lRYi1lCEb6kEzkAJB+u32Bed+Vbxy9hrIAD6RBfD+U=
=67vU
-----END PGP SIGNATURE-----
--=-=-=--

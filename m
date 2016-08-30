Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2] NFS4: Avoid migration loops
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <2d5aa23805b845cff3c28c4d6c71bb06173f0f15.1472563050.git.bcodding@redhat.com>
Date: Tue, 30 Aug 2016 12:39:43 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Message-Id: <11F118A6-7FE3-462A-9217-17B7C45411CA@oracle.com>
References: <C654261E-107D-4CB0-A345-E45BC4401F65@redhat.com> <2d5aa23805b845cff3c28c4d6c71bb06173f0f15.1472563050.git.bcodding@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 30, 2016, at 9:20 AM, Benjamin Coddington <bcodding@redhat.com> =
wrote:
>=20
> Change from v1:
> 	Use ELOOP rather than EEXIST, and drop the now-redundant =
comment.
>=20
> =
8<------------------------------------------------------------------------=
-
>=20
> If a server returns itself as a location while migrating, the client =
may
> end up getting stuck attempting to migrate twice to the same server.  =
Catch
> this by checking if the nfs_client found is the same as the existing
> client.  For the other two callers to nfs4_set_client, the nfs_client =
will
> always be ERR_PTR(-EINVAL).
>=20
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>

I don't have any objection.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> fs/nfs/nfs4client.c | 5 +++++
> 1 file changed, 5 insertions(+)
>=20
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 8d7d08d4f95f..cd3b7cfdde16 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -817,6 +817,11 @@ static int nfs4_set_client(struct nfs_server =
*server,
> 		goto error;
> 	}
>=20
> +	if (server->nfs_client =3D=3D clp) {
> +		error =3D -ELOOP;
> +		goto error;
> +	}
> +
> 	/*
> 	 * Query for the lease time on clientid setup or renewal
> 	 *
> --=20
> 2.5.5
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever

Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: Coddington Benjamin <bcodding@redhat.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Schumaker Anna
	<anna.schumaker@netapp.com>
Subject: Re: [PATCH] NFS4: Avoid migration loops
Date: Tue, 30 Aug 2016 12:53:21 +0000
Message-ID: <5B8891FB-1A45-4398-8881-5D72B1C250D7@primarydata.com>
References: <C654261E-107D-4CB0-A345-E45BC4401F65@redhat.com>
In-Reply-To: <C654261E-107D-4CB0-A345-E45BC4401F65@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 30, 2016, at 07:13, Benjamin Coddington <bcodding@redhat.com> wrot=
e:
>=20
> If a server returns itself as a location while migrating the client may
> end up getting stuck attempting to migrate twice to the same server.  Cat=
ch
> this by checking if the nfs_client found is the same as the existing
> client.  For the other two callers to nfs4_set_client, the nfs_client wil=
l
> always be ERR_PTR(-EINVAL);
>=20
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
> fs/nfs/nfs4client.c | 6 ++++++
> 1 file changed, 6 insertions(+)
>=20
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 8d7d08d4f95f..ec8afc43d849 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -817,6 +817,12 @@ static int nfs4_set_client(struct nfs_server *server=
,
> =09=09goto error;
> =09}
>=20
> +=09/* This client is already set, is there a migration loop? */
> +=09if (server->nfs_client =3D=3D clp) {
> +=09=09error =3D -EEXIST;
> +=09=09goto error;
> +=09}
> +

Good catch, but why the choice of EEXIST? It sounds as if there is a good a=
rgument for ELOOP, since this situation would literally mirror the self-ref=
erencing symlink case.

Cheers
   Trond

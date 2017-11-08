Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52577 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754147AbdKHDan (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Nov 2017 22:30:43 -0500
From: NeilBrown <neilb@suse.com>
To: Joshua Watt <jpewhacker@gmail.com>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 08 Nov 2017 14:30:32 +1100
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>
Subject: Re: NFS Force Unmounting
In-Reply-To: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
References: <1508951506.2542.51.camel@gmail.com> <20171030202045.GA6168@fieldses.org> <87h8ugwdev.fsf@notabene.neil.brown.name> <1509557061.4755.27.camel@redhat.com> <87efphvbhy.fsf@notabene.neil.brown.name> <1509624549.4569.28.camel@redhat.com> <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
Message-ID: <87fu9ph2g7.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


What to people think of the following as an approach
to Joshua's need?

It isn't complete by itself: it needs a couple of changes to
nfs-utils so that it doesn't stat the mountpoint on remount,
and it might need another kernel change so that the "mount" system
call performs the same sort of careful lookup for remount as  the umount
system call does, but those are relatively small details.

This is the patch that you will either love of hate.

With this patch, Joshua (or any other sysadmin) could:

  mount -o remount,retrans=3D0,timeo=3D1 /path

and then new requests on any mountpoint from that server will timeout
quickly.
Then
  umount -f /path
  umount -f /path

should kill off any existing requests that use the old timeout. (I just
tested and I did need this twice to kill of an "ls -l".
The first was an 'open' systemcall, then next as 'newfstat'. I wonder
why the getattr for fstat didn't use the new timeout...)

Thoughts?
NeilBrown

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c9d24bae3025..ced12fcec349 100644
=2D-- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2210,27 +2210,39 @@ static int nfs_validate_text_mount_data(void *optio=
ns,
 		~(NFS_MOUNT_UNSHARED | NFS_MOUNT_NORESVPORT))
=20
 static int
=2Dnfs_compare_remount_data(struct nfs_server *nfss,
=2D			 struct nfs_parsed_mount_data *data)
+nfs_compare_and_set_remount_data(struct nfs_server *nfss,
+				 struct nfs_parsed_mount_data *data)
 {
 	if ((data->flags ^ nfss->flags) & NFS_REMOUNT_CMP_FLAGMASK ||
 	    data->rsize !=3D nfss->rsize ||
 	    data->wsize !=3D nfss->wsize ||
 	    data->version !=3D nfss->nfs_client->rpc_ops->version ||
 	    data->minorversion !=3D nfss->nfs_client->cl_minorversion ||
=2D	    data->retrans !=3D nfss->client->cl_timeout->to_retries ||
 	    !nfs_auth_info_match(&data->auth_info, nfss->client->cl_auth->au_flav=
or) ||
 	    data->acregmin !=3D nfss->acregmin / HZ ||
 	    data->acregmax !=3D nfss->acregmax / HZ ||
 	    data->acdirmin !=3D nfss->acdirmin / HZ ||
 	    data->acdirmax !=3D nfss->acdirmax / HZ ||
=2D	    data->timeo !=3D (10U * nfss->client->cl_timeout->to_initval / HZ) =
||
 	    data->nfs_server.port !=3D nfss->port ||
 	    data->nfs_server.addrlen !=3D nfss->nfs_client->cl_addrlen ||
 	    !rpc_cmp_addr((struct sockaddr *)&data->nfs_server.address,
 			  (struct sockaddr *)&nfss->nfs_client->cl_addr))
 		return -EINVAL;
=20
+	if (data->retrans !=3D nfss->client->cl_timeout->to_retries ||
+	    data->timeo !=3D (10U * nfss->client->cl_timeout->to_initval / HZ)) {
+		/* Note that this will affect all mounts from the same server,
+		 * that use the same protocol.  The timeouts are always forced
+		 * to be the same.
+		 */
+		struct rpc_clnt *cl =3D nfss->client;
+		if (cl->cl_timeout !=3D &cl->cl_timeout_default)
+			memcpy(&cl->cl_timeout_default, cl->cl_timeout,
+			       sizeof(struct rpc_timeout));
+		cl->cl_timeout_default.to_retries =3D data->retrans;
+		cl->cl_timeout_default.to_initval =3D data->timeo * HZ / 10U;
+	}
+
 	return 0;
 }
=20
@@ -2244,7 +2256,8 @@ nfs_remount(struct super_block *sb, int *flags, char =
*raw_data)
 	struct nfs4_mount_data *options4 =3D (struct nfs4_mount_data *)raw_data;
 	u32 nfsvers =3D nfss->nfs_client->rpc_ops->version;
=20
=2D	sync_filesystem(sb);
+	if (sb->s_readonly_remount)
+		sync_filesystem(sb);
=20
 	/*
 	 * Userspace mount programs that send binary options generally send
@@ -2295,7 +2308,7 @@ nfs_remount(struct super_block *sb, int *flags, char =
*raw_data)
 		*flags |=3D MS_SYNCHRONOUS;
=20
 	/* compare new mount options with old ones */
=2D	error =3D nfs_compare_remount_data(nfss, data);
+	error =3D nfs_compare_and_set_remount_data(nfss, data);
 out:
 	kfree(data);
 	return error;

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloCeloACgkQOeye3VZi
gbnPlw//UIodNi+DyuBI3ZpIX7KpVNfQAB8HM+/1mf9ABt7ipmXCQrXfmJUplez2
5pf6GZL87rheNHVD6trfgC1nXbw+5TUzo1P4kSGVvrM33B/T9XwznmjLa5QPvfJ9
oszjKrdKql3NpRzvEBHyXFg4mo8i9UvNlis+Z2TBuIC6GyDUpUFxChgZGehCH+2q
i5TW1o58HIDg9ifpcs8fiKLky7k3+vC41WKMqtztudAf810yww/US7eyx8ZGnqPn
VyIPvw8X1iOsCeDJRM6HqwDspTEkSk3BmQWgvz0EITpPg8yc789cKllJ9DoKEQ9O
wBwWX1rZs2duM3H6i4xh1/XJZ14JLmh/OwF7334qygLt4ZiYDAB8NHI/fPrzULnO
p9sBKbNRlbpwSBcyR/mE/7gznAzavf/A40X6uzERwcNKIOrAG1IkeIk15++Zjvlk
gkhXXT1xMn90kB4Pvq5JxviSbhGDul3Z4ZVHioewlSpQGsZa6aQ+wKwHgBzN5Jqi
5xtkO5+blIRLyq7bgLtX8fR7AygGpT8KuOupOk3ZpBy/XkAPtgjUj7XrvDocRWp5
TIWCHzL/wT3wTzNvJWbW/XLjMZL/a+Dc0LXiJ3RXRQTSeIB+cseHYFq0KQFb4yy8
WNg/1meKgehn8WUH5qMu3/QFqb9/Y2oqST7tNWNuRBDM8ykjcM4=
=gHYc
-----END PGP SIGNATURE-----
--=-=-=--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51073 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750760AbdAMAEj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Jan 2017 19:04:39 -0500
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>
Date: Fri, 13 Jan 2017 11:04:27 +1100
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Cc: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: tidy up nfs_show_mountd_netid
In-Reply-To: <20161207170350.nycnsb3sduho5nu4@tonberry.usersys.redhat.com>
References: <1479243592-38858-1-git-send-email-smayhew@redhat.com> <56E2C0D6-40A3-45E9-815C-A50A94A3A95C@primarydata.com> <20161116135533.fytzlidwltjpz67e@tonberry.usersys.redhat.com> <20161207170350.nycnsb3sduho5nu4@tonberry.usersys.redhat.com>
Message-ID: <87inpjhlkk.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


This function is a bit clumsy, incorrectly producing
",mountproto=3D" if mountd_protocol is 0 and !showdefaults,
and duplicating the code for reporting "auto".

Tidy it up so that it only makes a single seq_printf() call,
and more obviously does the right thing.

Fixes: ee671b016fbf ("NFS: convert proto=3D option to use netids rather tha=
n a protoname")
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

While I don't object to Scott's patch to fix this issue, this is a
function that could usefully be simplified as well as fixed, so I offer
my own alternative.... partly just to keep the email-thread alive.

Quite apart from whether this function *should* be called for v3
submounts, I think it would be good for the function to be robust.

Thanks,
NeilBrown


 fs/nfs/super.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6bca17883b93..54e0f9f2dd94 100644
=2D-- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -531,39 +531,32 @@ static void nfs_show_mountd_netid(struct seq_file *m,=
 struct nfs_server *nfss,
 				  int showdefaults)
 {
 	struct sockaddr *sap =3D (struct sockaddr *) &nfss->mountd_address;
+	char *proto =3D NULL;
=20
=2D	seq_printf(m, ",mountproto=3D");
 	switch (sap->sa_family) {
 	case AF_INET:
 		switch (nfss->mountd_protocol) {
 		case IPPROTO_UDP:
=2D			seq_printf(m, RPCBIND_NETID_UDP);
+			proto =3D RPCBIND_NETID_UDP;
 			break;
 		case IPPROTO_TCP:
=2D			seq_printf(m, RPCBIND_NETID_TCP);
+			proto =3D RPCBIND_NETID_TCP;
 			break;
=2D		default:
=2D			if (showdefaults)
=2D				seq_printf(m, "auto");
 		}
 		break;
 	case AF_INET6:
 		switch (nfss->mountd_protocol) {
 		case IPPROTO_UDP:
=2D			seq_printf(m, RPCBIND_NETID_UDP6);
+			proto =3D RPCBIND_NETID_UDP6;
 			break;
 		case IPPROTO_TCP:
=2D			seq_printf(m, RPCBIND_NETID_TCP6);
+			proto =3D RPCBIND_NETID_TCP6;
 			break;
=2D		default:
=2D			if (showdefaults)
=2D				seq_printf(m, "auto");
 		}
 		break;
=2D	default:
=2D		if (showdefaults)
=2D			seq_printf(m, "auto");
 	}
+	if (proto || showdefaults)
+		seq_printf(m, ",mountproto=3D%s", proto ?: "auto");
 }
=20
 static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server =
*nfss,
=2D-=20
2.11.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlh4GYwACgkQOeye3VZi
gblgSQ/+I+gaYgs7WIsfwPEtirxORiRUZpJHbOi3+ZDGZW27xqNsP3tGp/PM4e6F
eqvRhieF/MBD1Q/Y2uxj90k8zvyaPLLqJE0YVzm4ulAOrWkVI2kXvvc1uQmXhvxB
K5ERzMoirMxJsIsIMLNpltIzBE1CZpQ2PjAFVS7Zfo5pt1qD6mqzwIjp3B+mgHVf
At6jsJhiE25twQRSd9HMHoru2/csqrBrmBAIpDzLMiJrWKv61afEArbUz1pcjgYK
7hEhdPJRE0gYclSuuxN0tmdHSS4I23xwW8oPYopn5TeTjI9UkIXtE5Aj5nlJ/OrG
QuNTxxZdl25xjTpV7o38gOqCyKmEpcEwxc5R4pt7Z3SxY4HUKhRtu4LCsQXgkAQ+
l+envJ7aDn4DfTkaSlvJXLKisPguBR2n9qLF6iSICODp0OpXyq26UyWDXISwlSEn
zJAN5oAnvLwgjsR52YV6DINHnV8Ms4I9S67SRF4sfmqQvCzOV2gwthC7qEIolrfS
+FPsXQXefxy+M8ywns6qEFUCKfz63aHwe8SHntibHvYQZmHrg/zulLaD+Zu98NZO
7cmgtcF2BdnqHuo9MH9A0J3nll86V1D8o2wNVWkXBJVmzYi3ojoxob4uMo4zwZ6c
8U2mvjmNQ6Qazwzy3hncXEq/gPT0I7K6ZD+pwTLHvPr0Z2UZHXk=
=Wtx6
-----END PGP SIGNATURE-----
--=-=-=--

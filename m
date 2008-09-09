From: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Tue, 9 Sep 2008 12:46:44 -0700
Message-ID: <20080909194644.GI5290@merfinllc.com>
References: <20080905191939.GG22796@merfinllc.com> <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com> <20080908190212.GF28123@merfinllc.com> <76bd70e30809081415h6b55a8dfl8171634c576ac946@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tSiBuZsJmMXpnp7T"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML Kernel <linux-kernel@vger.kernel.org>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from quackingmoose.com ([63.73.180.143]:58075 "EHLO
	penguin.merfinllc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753427AbYIITqp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2008 15:46:45 -0400
In-Reply-To: <76bd70e30809081415h6b55a8dfl8171634c576ac946-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--tSiBuZsJmMXpnp7T
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Sep 08 05:15 PM, Chuck Lever wrote:
> I think I saw some recent work in Trond's development branch that
> makes some changes in this area.  I will wait for him to respond to
> this thread.

One other piece of information.

Of the bisected offending commit:

commit e261f51f25b98c213e0b3d7f2109b117d714f69d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 5 00:35:41 2006 -0500

    NFS: Make nfs_updatepage() mark the page as dirty.
   =20
    This will ensure that we can call set_page_writeback() from within
    nfs_writepage(), which is always called with the page lock set.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


It seems to be this hunk which introduces the problem:


@@ -628,7 +667,6 @@ static struct nfs_page * nfs_update_request(struct nfs_=
open_context* ctx,
 				return ERR_PTR(error);
 			}
 			spin_unlock(&nfsi->req_lock);
-			nfs_mark_request_dirty(new);
 			return new;
 		}
 		spin_unlock(&nfsi->req_lock);



If I add that function call back in... the problem disappears.  I don't
know if this just papers over the real problem though? =20


					Thanks,
					=3Da=3D





--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Aaron Straus
aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org

--tSiBuZsJmMXpnp7T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFIxtKkr/o4YuvB+jgRAt+CAKDi6826th7ohL2HY/9z4yxvIpw53gCghZHe
MRq7nJqH7u83oKHTAZYgcYo=
=MR8a
-----END PGP SIGNATURE-----

--tSiBuZsJmMXpnp7T--

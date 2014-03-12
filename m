Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38401 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353AbaCLFzd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2014 01:55:33 -0400
Date: Wed, 12 Mar 2014 16:55:26 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - v3] mount.nfs: Fix fallback from tcp to udp
Message-ID: <20140312165526.76332207@notabene.brown>
In-Reply-To: <1394551050-14571-1-git-send-email-steved@redhat.com>
References: <1394551050-14571-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/IFibI=RvRprhqC5dQXsUvwN"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/IFibI=RvRprhqC5dQXsUvwN
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 11 Mar 2014 11:17:30 -0400 Steve Dickson <steved@redhat.com> wrote:

> From: NeilBrown <neilb@suse.de>
>=20
> Protocol negotiation in mount.nfs does not correctly negotiate with a
> server which only supports NFSv3 and UDP.
>=20
> When mount.nfs attempts an NFSv4 mount and fails with ECONNREFUSED
> it does not fall back to NFSv3, as this is not recognised as a
> "does not support NFSv4" error.
> However ECONNREFUSED is a clear indication that the server doesn't
> support TCP, and ipso facto does not support NFSv4.
> So ECONNREFUSED should trigger a fallback from v4 to v2/3.
>=20
> However ECONNREFUSED may simply indicate that NFSv4 isn't supported
> *yet*.  i.e. the server is still booting and isn't responding to NFS
> requests yet.  So if we subsequently find that NFSv3 is supported, we
> need to check with the server to confirm that NFSv4 really isn't
> supported.
>=20
> If server reports that v4 is not supported after reporting that v3
> is, we can safely use v4.  If it reports that v4 is supported, we need
> to retry v4.
>=20
> Signed-off-by: Steve Dickson <steved@redhat.com>
> Reported-by: Carsten Ziepke <kieltux@gmail.com>
> ---


> +		memcpy(&save_sa, sap, salen);
> +
> +		ret =3D nfs_probe_port(sap, salen, pmap,
> +				     probe_nfs3_only, probe_proto);
> +		if (!ret || !checkv4 || probe_proto !=3D probe_tcp_first)
> +			return ret;
> +
> +		nfs_set_port((struct sockaddr *)&save_sa, NFS_PORT);
> +		ret =3D  nfs_rpc_ping((struct sockaddr *)&save_sa, salen,=20
> +			NFS_PROGRAM, 4, IPPROTO_TCP, NULL);

That turns out to be very neat, doesn't it?
I'm quite happy with this version instead.

Thanks,
NeilBrown

--Sig_/IFibI=RvRprhqC5dQXsUvwN
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUx/2zjnsnt1WYoG5AQLtfQ/9FXUT2c4H4n+L43bTLkkG5VuG5Au07t3e
gb72PT9L3MSKB04JqUpPypAbe4BU7DasKW0hgCjT5Cw0ircZVDuQcAXJ0garKFuC
Skg5zdVUAA6XiYToaZ1FXaFOj8PJ8WkY9/tsNxfvrgesv/01OIPla25/fU+2KbYg
6whqSu+dlOzXVWFxhvil9UWjNXp2A2OXtdkoc33wQ6NfvNDmOXUSvrK/shQ2zKPq
HRE6yFXWbsvLn9jmwVT51lu1/F82kD5lwra+8DsTAcuGl9VyTWYqTXhr4JTJUDVy
jSDZ1mBO4WbLL3QpdbihCrxbws8BUcf2JUf7ttH4Idg3BRX6E+o8uCrestTIMvOE
16uHbSoyIeJZkyctChMOYhy77K/DxhaAGwXWhidrE1HBYqWLeU3FcO6CacYXRC6A
n01uQmRFl1VI/YLhMjAfZTvQrKCa0SvPLksobIZXDG1xZBZnuAKS6mOBn04dL5rh
iUZ1v774lJouy1xHX+BHQhgpEROOJzK4ui0VUIEQ3e4ofKVJnk6C4yjwjZFJmdTa
2SRVoABcLQrv674XbkgCeb2nIo7QRm+wujw0NilzzfjfNJTdDLstJN1OT17JOxYx
9RMhpnnYeJ1dl5AhK9BFjS/Q/L5FNlo7RYtgurmZdhMEVBCiqzUjCIJbYWKaZrHf
HB3razAHG4Q=
=+Zrw
-----END PGP SIGNATURE-----

--Sig_/IFibI=RvRprhqC5dQXsUvwN--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47504 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897AbaELBGH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 21:06:07 -0400
Date: Mon, 12 May 2014 11:05:57 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/5] nfsd: Only set PF_LESS_THROTTLE when really needed.
Message-ID: <20140512110557.67f2028e@notabene.brown>
In-Reply-To: <20140506205418.GQ18281@fieldses.org>
References: <20140423022441.4725.89693.stgit@notabene.brown>
	<20140423024058.4725.38098.stgit@notabene.brown>
	<20140506205418.GQ18281@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/_V4z.i1JTXug8PX71jSjKud"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/_V4z.i1JTXug8PX71jSjKud
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 6 May 2014 16:54:18 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, Apr 23, 2014 at 12:40:58PM +1000, NeilBrown wrote:
> > PF_LESS_THROTTLE has a very specific use case: to avoid deadlocks
> > and live-locks while writing to the page cache in a loop-back
> > NFS mount situation.
> >=20
> > It therefore makes sense to *only* set PF_LESS_THROTTLE in this
> > situation.
> > We now know when a request came from the local-host so it could be a
> > loop-back mount.  We already know when we are handling write requests,
> > and when we are doing anything else.
> >=20
> > So combine those two to allow nfsd to still be throttled (like any
> > other process) in every situation except when it is known to be
> > problematic.
>=20
> Looks simple enough, ACK.--b.
>=20

Thanks.
I'll resend the bits need for just this.

The NFS side need to wait for wait_on_bit improvements which seem to be on a
slow path at the moment.

Thanks,
NeilBrown

--Sig_/_V4z.i1JTXug8PX71jSjKud
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU3AedTnsnt1WYoG5AQLtVQ//ca3F1FKgZ1bg4vldC4AC0h6yeS6OW2kb
71BlpBNF69xL/yY56j2JTOtxf/SDJxf/UGPjChxpaIpcf/npZPPT4mfUL+7AruNm
pBbLtenwSnU0GRvCuDednJwt33mZ33minfW7Gzhsc1Uj2s0Rd0yaUnio7DTNBpgI
KuIgcN/LKuEz+u+ItEpcQ3fCE0uOS8/W9prYPcyZvHH+DrwyLwpHFz2CV2WNsdRZ
zpwRb8aQNXTnJKuTDgUieZOIB9/eSK5+uznhzd7VwcRhdAU4edduI26gVNxjkgZb
zDggyM55TyNxtDK/hSTWpmHYybI9dznUDNkQs3FVzGyw/dGKxLHxY2X2FkNLleUr
yqpqMla309OOm4/gAL/vCaLUTVtyirOqJbyn6Qtv3qFccG2HnRp4qvk+YLMIZuyF
5cxg56+3KXGRvES08KJchzk+RP9lpShyhAuyUJEZV2DmyvAFDUbMrKakkVEyeUnj
F69+uEccPX3qZ3E0Z4Yo5ryaZGcndeevVYgFDTQn0GvKleLNK3oclVtIM+d68Duq
jzeh/Ejj0j2TGgzPs0clQ1EDLCC81ka/GHEeBkVLaejV0Yd9b/MovwxFf4UZQbkJ
8AqoHzmWrj4k3qe7uHwXRzi4AlzFBbt3/nqXy3ROkNJCdbMVblzJxsihv7bGX+tf
29nSQoHbuT4=
=epl8
-----END PGP SIGNATURE-----

--Sig_/_V4z.i1JTXug8PX71jSjKud--

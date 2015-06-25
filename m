Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mo4-p05-ob.smtp.rzone.de ([81.169.146.181]:12469 "EHLO
	mo4-p05-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbbFYUFA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 16:05:00 -0400
Message-ID: <558C5D75.6050608@samba.org>
Date: Thu, 25 Jun 2015 21:58:45 +0200
From: "Stefan (metze) Metzmacher" <metze@samba.org>
MIME-Version: 1.0
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        samba-technical@lists.samba.org, linux-security-module@vger.kernel.org
Subject: Re: [RFC v4 06/31] richacl: In-memory representation and helper functions
References: <1435183040-22726-1-git-send-email-agruenba@redhat.com> <1435183040-22726-7-git-send-email-agruenba@redhat.com>
In-Reply-To: <1435183040-22726-7-git-send-email-agruenba@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="QcxN29qXk8Xkw7dkUjF2iWHhCpuWdK8Vv"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QcxN29qXk8Xkw7dkUjF2iWHhCpuWdK8Vv
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Andreas,

> +#define RICHACE_OWNER_SPECIAL_ID	0
> +#define RICHACE_GROUP_SPECIAL_ID	1
> +#define RICHACE_EVERYONE_SPECIAL_ID	2
> +
> +struct richace {
> +	unsigned short	e_type;
> +	unsigned short	e_flags;
> +	unsigned int	e_mask;
> +	union {
> +		kuid_t		uid;
> +		kgid_t		gid;
> +		unsigned int	special;
> +	} e_id;
> +};
> +
> +struct richacl {
> +	atomic_t	a_refcount;
> +	unsigned int	a_owner_mask;
> +	unsigned int	a_group_mask;
> +	unsigned int	a_other_mask;
> +	unsigned short	a_count;
> +	unsigned short	a_flags;
> +	struct richace	a_entries[0];
> +};

Is that also the on disk representation?

I'm wondering if the size of an ace should be dynamic,
which might make it possible to support other ace types
in future. E.g. supporting other identities like 128-bit values
to make it easier to map Windows SIDS.

Even without 128-bit ids, it would be very useful to mark an
ace so that it applies to a uid or gid at the same time.
This would reduce the size of the ace list when Samba uses
IDMAP_TYPE_BOTH, which means a SID is mapped to a unix id, which
is user (uid) and group (gid) at the same time. This feature is required
in order to support SID-Histories on accounts.
Currently Samba needs to add two aces (one uid and one gid)
in order to represent one Windows ace.

I haven't looked at the claims based acls on Windows, but it would be
good if the new infrastructure is dynamic enough to support something
like that in a future version.

Thanks very much on your persistent to bring richacls forward!

metze


--QcxN29qXk8Xkw7dkUjF2iWHhCpuWdK8Vv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEUEARECAAYFAlWMXXkACgkQm70gjA5TCD+E+ACgzY4eEne/+mbPaeueSYN80wqv
WtQAmLy/OellwD9vtiw4M55Jfu95w0E=
=am4e
-----END PGP SIGNATURE-----

--QcxN29qXk8Xkw7dkUjF2iWHhCpuWdK8Vv--

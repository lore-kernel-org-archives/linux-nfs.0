Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mo4-p05-ob.smtp.rzone.de ([81.169.146.181]:22790 "EHLO
	mo4-p05-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbbFYVk2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 17:40:28 -0400
Message-ID: <558C7535.9050502@samba.org>
Date: Thu, 25 Jun 2015 23:40:05 +0200
From: "Stefan (metze) Metzmacher" <metze@samba.org>
MIME-Version: 1.0
To: =?UTF-8?B?QW5kcmVhcyBHcsO8bmJhY2hlcg==?=
	<andreas.gruenbacher@gmail.com>
CC: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>,
        samba-technical <samba-technical@lists.samba.org>,
        linux-security-module@vger.kernel.org
Subject: Re: [RFC v4 06/31] richacl: In-memory representation and helper functions
References: <1435183040-22726-1-git-send-email-agruenba@redhat.com>	<1435183040-22726-7-git-send-email-agruenba@redhat.com>	<558C5D75.6050608@samba.org> <CAHpGcM+AwRubQqX96V3WbwLKXKTfk3YcgFG_eqG6r7cVbCTV-w@mail.gmail.com>
In-Reply-To: <CAHpGcM+AwRubQqX96V3WbwLKXKTfk3YcgFG_eqG6r7cVbCTV-w@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="aC1M27CKf9tWKRLKcLCCiKarTR1aSIoOt"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--aC1M27CKf9tWKRLKcLCCiKarTR1aSIoOt
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Andreas,

>> I'm wondering if the size of an ace should be dynamic,
>> which might make it possible to support other ace types
>> in future. E.g. supporting other identities like 128-bit values
>> to make it easier to map Windows SIDS.
>=20
> I'm working on additionally supporting unmapped user@domain and
> group@domain identifier strings; we have to deal with that case in the
> nfs client; that may be useful for Samba as well.

Can this be any string? So would
"S-1-5-21-4052121579-2079768045-1474639452-1001" also work?

How would the current thread/process get a "token" that would match such
an ace?

>> Even without 128-bit ids, it would be very useful to mark an
>> ace so that it applies to a uid or gid at the same time.
>> This would reduce the size of the ace list when Samba uses
>> IDMAP_TYPE_BOTH, which means a SID is mapped to a unix id, which
>> is user (uid) and group (gid) at the same time. This feature is requir=
ed
>> in order to support SID-Histories on accounts.
>> Currently Samba needs to add two aces (one uid and one gid)
>> in order to represent one Windows ace.
>=20
> It's not clear to me if supporting this would be a good idea right now.=

> The kernel would have to treat each such entry like two separate entrie=
s
> internally. How would we map a combined user-space "uid + gid"
> number to a kernel uid and gid since it could map to two distinct
> numbers there?

No, the numeric value is the same.

I think richacl_permission() is the only place that requires any action.

	richacl_for_each_entry(ace, acl) {
		unsigned int ace_mask =3D ace->e_mask;

		if (richace_is_inherit_only(ace))
			continue;
		if (richace_is_owner(ace)) {
			if (!uid_eq(current_fsuid(), inode->i_uid))
				continue;
		} else if (richace_is_group(ace)) {
			if (!in_owning_group)
				continue;
+		} else if (richace_is_unix_both(ace)) {
+			kuid_t uid =3D current_fsuid();
+
+			if (!uid_eq(uid, ace->e_id.xid) && !in_group_p(ace->e_id.xid))
+				continue;
		} else if (richace_is_unix_user(ace)) {
			kuid_t uid =3D current_fsuid();

			if (!uid_eq(uid, ace->e_id.uid))
				continue;
		} else if (richace_is_unix_group(ace)) {
			if (!in_group_p(ace->e_id.gid))
				continue;
		} else
			goto entry_matches_everyone;

In general shouldn't kuid_t uid =3D current_fsuid(); be at the top of the=

function just once?

>> I haven't looked at the claims based acls on Windows, but it would be
>> good if the new infrastructure is dynamic enough to support something
>> like that in a future version.
>=20
> I don't know, I have yet to see a use case that isn't totally crazy.

Ok, I found the a_version in struct richacl_xattr.

metze


--aC1M27CKf9tWKRLKcLCCiKarTR1aSIoOt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlWMdTgACgkQm70gjA5TCD8w2ACdEy9YtMXiH2k8cKTgcQm9nKeJ
em0AnAykqCZgGuPWl8KTjX7vgJNcirg2
=0Opo
-----END PGP SIGNATURE-----

--aC1M27CKf9tWKRLKcLCCiKarTR1aSIoOt--

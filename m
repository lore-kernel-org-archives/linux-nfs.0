Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44424 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751336AbdHaX2G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 Aug 2017 19:28:06 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Date: Fri, 01 Sep 2017 09:27:54 +1000
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
In-Reply-To: <20170831190531.GA8223@parsley.fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com> <1503697958-6122-3-git-send-email-bfields@redhat.com> <878ti4i9pi.fsf@notabene.neil.brown.name> <20170829214026.GI8822@parsley.fieldses.org> <8760d5hol3.fsf@notabene.neil.brown.name> <20170830170938.GC24373@parsley.fieldses.org> <87wp5kfxi3.fsf@notabene.neil.brown.name> <20170831190531.GA8223@parsley.fieldses.org>
Message-ID: <873787fhc5.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 31 2017, J. Bruce Fields wrote:

> On Thu, Aug 31, 2017 at 09:26:28AM +1000, NeilBrown wrote:
>> On Wed, Aug 30 2017, J. Bruce Fields wrote:
>>=20
>> > On Wed, Aug 30, 2017 at 10:43:52AM +1000, NeilBrown wrote:
>> >> I'm suggesting that nfsd have a local "struct deleg_break_ctl" (or
>> >> whatever name you like) which contains a 'struct inode *delegated_ino=
de'
>> >> plus whatever else is useful to nfsd.
>> >> Then nfsd/vfs.c, when it calls things like vfs_unlink(), passes
>> >>  &dbc.delegated_inode
>> >> (where 'struct deleg_break_ctl dbc').
>> >> So the vfs codes doesn't know about 'struct deleg_break_ctl', it just
>> >> knows about the 'struct inode ** inodep' like it does now, though wit=
h the
>> >> understanding that "DELEG_NO_WAIT" in the **inodep means that same as
>> >> inodep=3D=3DNULL.
>> >>=20
>> >> The vfs passes this same 'struct **inode' to lm_breaker_owns_lease() =
and
>> >> the nfsd code uses
>> >>    dbc =3D container_of(inodep, struct deleg_break_ctl, delegated_ino=
de)
>> >> to get the dbc, and it can use the other fields however it likes.
>> >
>> > Oh, now I understand.  That's an interesting idea.  I don't *think* it
>> > works on its own, because I don't think we've got a way in that case to
>> > know whether the passed-down delegated inode came from nfsd (and thus =
is
>> > contained in a deleg_break_ctl structure).  We get the
>> > lm_breaker_owns_lease operation from the lease that's already set on t=
he
>> > inode, but we don't know who that breaking operation is coming from.
>>=20
>> That is a perfectly valid criticism and one that, I think, applies
>> equally to your original code.
>>=20
>>  +static bool nfsd_breaker_owns_lease(void *who, struct file_lock *fl)
>>  +{
>>  +	struct svc_rqst *rqst =3D who;
>>=20
>> How does nfsd know that 'who' is an svc_rqst??
>
> Only nfsd fills in the "who" field of deleg_break_ctl.  But non-nfsd
> users do need to pass a non-NULL delegated_inode.

Yes, of course...

So having been wrong about this code twice, I'm starting to get a feel
for what it does and why.  I still wonder if there might be a better
approach though.

You are changing the interface to pass a magic cookie with the meaning
"Don't bother breaking a delegation which matches this magic cookie".
Would it not be better to pass a delegation, and say "Don't bother
breaking this delegation".  And if it were a WRITE delegation, that
could be optimised as "don't bother breaking any delegation, I have a
write delegation so I have exclusive access".

Whenever we call a vfs_* function that will need to break delegations we
have already done the lookup and have the dentry and inode, so finding a
delegation shouldn't be prohibitive.

nfsd would need to find that delegation, prevent further delegations
being handed out, and check that there aren't already conflicting
delegations.  If there are conflicts, recall them.  Once there are no
conflicting delegations, make the vfs_ request.
One downside of this is that nfsd delegations would be recalled before
any others, rather than doing them all in parallel.  This could be
addressed by calling try_break_deleg() when recalling the nfsd
delegations.

This approach seems to be half-way between your original attempt that
you described, which is racy, and the attempt you posted which adds the
callback that I don't particularly like.

???

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmom3wACgkQOeye3VZi
gbniNxAAjp92FkUQrfeFjGhcg2xF4on5mHXKZmWkFAnDR9hBweLkxzWyGDZWos/O
tnA+Gy9prnXxPYc4WdE53mdvYwPBJUT9IvfGkCMlT4Bzfm2tYWcBKda7sTkjyc5M
ikFuvFyBuHUYBUh1ycFawgy91BZu4dkPrA8Hy/6HzTsdoFwrRTdc0QUJkjBRhXI8
MMK5rDAB2ky8jYhiiOkrxby8POn50DO00Khoc9omvLi4a38YU5cR0FTTnVsrlVrO
FR92rkXf3WRONOutOyAVmZ3N2fEHtiWxeuUZP1n4vN2sCEk/E5/nWyS42QH7mZYi
Cfp+RC0o28WBFLjLBqiksLcsfUSYBYUEmPDSd1c+qgq6qGTIDykbNjHakf9tAoI9
lvk2t9akudNPQeFbeBBEuX/pG4ShAWcDgrDrJa1TMXdgL/5+iy25rE2TsXVb/Vj0
uz5vxxRc7cvZvK2JaXZTEuvfnIIrqGHh1UAJXRV18pIlwMi9rBbzXlWogHUtCizi
fIwcfjQpJQvWuLn5mN9VgvriElLzUks1To3FOa+f+A79BTTXjC1dNwdJiT6k5/x/
Edxji9zAf2gqyhRUIlD13UOpF1rv6Ytn0eHCO3OtppgBXTBJzhDZIu8SUQ8aG4lD
id78cW/r7y9/2jsOAuRhOzqilWvCkK2FbPg4+2aVyYc31nkOpX8=
=lDYd
-----END PGP SIGNATURE-----
--=-=-=--

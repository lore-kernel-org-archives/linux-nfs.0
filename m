Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50445 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751127AbdH3X0l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Aug 2017 19:26:41 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Date: Thu, 31 Aug 2017 09:26:28 +1000
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
In-Reply-To: <20170830170938.GC24373@parsley.fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com> <1503697958-6122-3-git-send-email-bfields@redhat.com> <878ti4i9pi.fsf@notabene.neil.brown.name> <20170829214026.GI8822@parsley.fieldses.org> <8760d5hol3.fsf@notabene.neil.brown.name> <20170830170938.GC24373@parsley.fieldses.org>
Message-ID: <87wp5kfxi3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 30 2017, J. Bruce Fields wrote:

> On Wed, Aug 30, 2017 at 10:43:52AM +1000, NeilBrown wrote:
>> On Tue, Aug 29 2017, J. Bruce Fields wrote:
>>=20
>> > On Mon, Aug 28, 2017 at 02:43:05PM +1000, NeilBrown wrote:
>> >> On Fri, Aug 25 2017, J. Bruce Fields wrote:
>> >>=20
>> >> > From: "J. Bruce Fields" <bfields@redhat.com>
>> >> >
>> >> > Pass around a new struct deleg_break_ctl instead of pointers to ino=
de
>> >> > pointers; in a future patch I want to use this to pass a little more
>> >> > information from the nfs server to the lease code.
>> >>=20
>> >> The information you are passing from the nfs server to the lease code=
 is
>> >> largely ignored by the lease code and is passed back to the nfs serve=
r,
>> >> in the sm_breaker_owns_lease call back.
>> >>=20
>> >> If try_break_deleg() passed the 'delegated_inode' pointer though to
>> >> __break_lease(), it could pass it through any_leases_conflict() and
>> >> leases_conflict() to the lm_breaker_owns_lease() callback.
>> >> Then container_of() could be used to access whatever other data nfsd =
had
>> >> stashed near the inode.  The common code wouldn't need to know any of
>> >> the details.
>> >
>> > The new information that we need is some notion of "who" (really, which
>> > NFSv4 client) is doing the operation (unlink, whatever) that breaks the
>> > lease.  We can't get that information from an inode pointer.
>> >
>> > I may just not understand your suggestion.
>>=20
>> Probably I was too terse.
>>=20
>> I'm suggesting that nfsd have a local "struct deleg_break_ctl" (or
>> whatever name you like) which contains a 'struct inode *delegated_inode'
>> plus whatever else is useful to nfsd.
>> Then nfsd/vfs.c, when it calls things like vfs_unlink(), passes
>>  &dbc.delegated_inode
>> (where 'struct deleg_break_ctl dbc').
>> So the vfs codes doesn't know about 'struct deleg_break_ctl', it just
>> knows about the 'struct inode ** inodep' like it does now, though with t=
he
>> understanding that "DELEG_NO_WAIT" in the **inodep means that same as
>> inodep=3D=3DNULL.
>>=20
>> The vfs passes this same 'struct **inode' to lm_breaker_owns_lease() and
>> the nfsd code uses
>>    dbc =3D container_of(inodep, struct deleg_break_ctl, delegated_inode)
>> to get the dbc, and it can use the other fields however it likes.
>
> Oh, now I understand.  That's an interesting idea.  I don't *think* it
> works on its own, because I don't think we've got a way in that case to
> know whether the passed-down delegated inode came from nfsd (and thus is
> contained in a deleg_break_ctl structure).  We get the
> lm_breaker_owns_lease operation from the lease that's already set on the
> inode, but we don't know who that breaking operation is coming from.

That is a perfectly valid criticism and one that, I think, applies
equally to your original code.

 +static bool nfsd_breaker_owns_lease(void *who, struct file_lock *fl)
 +{
 +	struct svc_rqst *rqst =3D who;

How does nfsd know that 'who' is an svc_rqst??

You can save your code by passing
   nfsd4_client_from_rqst(rqst)

as the 'who', and then testing
 +		if (dl->dl_stid.sc_client !=3D who) {

in the loop in nfsd_breaker_owns_lease.  So the only action performed
on the void* is an equality test.

I cannot save my code quite so easily. :-(

Thanks,
NeilBrown


>
> Maybe something alon those lines could be made to work.
>
>> Then instead of the rather task-specific name "lm_breaker_owns_lease" we
>> could have a more general name like "lm_lease_compatible" ... or
>> something.  "lm_break_doesn't_see_this_lease_as_being_in_conflict" is a
>> bit long, and contains "'".
>
> Hah, yes.--b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmnSacACgkQOeye3VZi
gbktgBAAtnx+bCSsAPFGtjRuM/OHlRgfg0lBqs+QfvupYGz47XzczSX10t9cK6zu
/RMxWJhroDcABhvCeZWvcGCrCkYZw3U5UkF+LWrr3AENDYtezYrlLp3+dYBZnlH5
hHesarkBt3Rn4KWUFxuyH3ejmDUXOqtCi5mk9HOIEuXkdIoSqSNDCCbIgD1XdXmW
EVvozLtp3KeTyqCGiEmhs6W6EE9TEUX9N++U1COECEsKqfWsgtiZuLFUPh6Cxwuh
tzmHOdbR4zMpwCtObPUpWi29Ni+QpWvgzK5scUxaPsUhYDlhql/4ujhjzaJ52D/f
qilY7K5GKeZcpYd4aTWYrN7F5g6ebXcFF+VhWP7IEBaYA9ic3g/WcXV5vczABm1L
q55xrw/BaBbuiXabTq/ATyVHue6WkcvXnufFZk117XJ4ZtLqmXORqjzHneZi4IHi
LVwQq4M/AhV2mBai6IMhdnXxsHMBkJw5lcsvN8dhkeiiTwC8qZNY6zjrdN6a3nxj
J4WFcGyUtO2ARJaUZKpMpkW9fVbZDhvXx9r7a3iLpJcxrqga9R/Iz9VvL/lv5Iye
PcXsvMOK6+9W7lu0bf8DsQEGxT95UXOIVbxVfZcS1bkFgec87NbdIRv6xopHxdSm
VxdHdCT0MXryqX69xZvVemiriEyZA7+j2YICvWeanpQQg6573gQ=
=1a2f
-----END PGP SIGNATURE-----
--=-=-=--

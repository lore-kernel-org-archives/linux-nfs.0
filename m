Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56922 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751290AbdH3AoC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Aug 2017 20:44:02 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Date: Wed, 30 Aug 2017 10:43:52 +1000
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
In-Reply-To: <20170829214026.GI8822@parsley.fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com> <1503697958-6122-3-git-send-email-bfields@redhat.com> <878ti4i9pi.fsf@notabene.neil.brown.name> <20170829214026.GI8822@parsley.fieldses.org>
Message-ID: <8760d5hol3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 29 2017, J. Bruce Fields wrote:

> On Mon, Aug 28, 2017 at 02:43:05PM +1000, NeilBrown wrote:
>> On Fri, Aug 25 2017, J. Bruce Fields wrote:
>>=20
>> > From: "J. Bruce Fields" <bfields@redhat.com>
>> >
>> > Pass around a new struct deleg_break_ctl instead of pointers to inode
>> > pointers; in a future patch I want to use this to pass a little more
>> > information from the nfs server to the lease code.
>>=20
>> The information you are passing from the nfs server to the lease code is
>> largely ignored by the lease code and is passed back to the nfs server,
>> in the sm_breaker_owns_lease call back.
>>=20
>> If try_break_deleg() passed the 'delegated_inode' pointer though to
>> __break_lease(), it could pass it through any_leases_conflict() and
>> leases_conflict() to the lm_breaker_owns_lease() callback.
>> Then container_of() could be used to access whatever other data nfsd had
>> stashed near the inode.  The common code wouldn't need to know any of
>> the details.
>
> The new information that we need is some notion of "who" (really, which
> NFSv4 client) is doing the operation (unlink, whatever) that breaks the
> lease.  We can't get that information from an inode pointer.
>
> I may just not understand your suggestion.

Probably I was too terse.

I'm suggesting that nfsd have a local "struct deleg_break_ctl" (or
whatever name you like) which contains a 'struct inode *delegated_inode'
plus whatever else is useful to nfsd.
Then nfsd/vfs.c, when it calls things like vfs_unlink(), passes
 &dbc.delegated_inode
(where 'struct deleg_break_ctl dbc').
So the vfs codes doesn't know about 'struct deleg_break_ctl', it just
knows about the 'struct inode ** inodep' like it does now, though with the
understanding that "DELEG_NO_WAIT" in the **inodep means that same as
inodep=3D=3DNULL.

The vfs passes this same 'struct **inode' to lm_breaker_owns_lease() and
the nfsd code uses
   dbc =3D container_of(inodep, struct deleg_break_ctl, delegated_inode)
to get the dbc, and it can use the other fields however it likes.

Then instead of the rather task-specific name "lm_breaker_owns_lease" we
could have a more general name like "lm_lease_compatible" ... or
something.  "lm_break_doesn't_see_this_lease_as_being_in_conflict" is a
bit long, and contains "'".

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmmCkoACgkQOeye3VZi
gbkT/A/+Igjbk2V5TWsgpe5UWJ1O0ZKtWC3NXfawDfPUsZ62AKTO6Or1pf/PDvA5
XiT8kZMKih5DcJwAJ4k9E/nrWqx0hn9G5t6VrpvXSA4+kJtFImmNKNU/yhs9PPoE
nsR6WaJAi+iO38/49MEYSAZKPx+tUIYba8uaDQUFPA4VCY2fLLJg1IupbLaebQHx
CYvyQhb/iTRDumn8cIO23tYpGpN6gxP0UOhsVy/iAwgs9M1GHihW3evXrXGzgIcc
Xmo/C86nhIpyxlPGdgEjrR1uGN4H+oacebqBNq/5hEGGP1Z6/SNYJiZP6CKPz61H
3rdmrAI5SPdpAuYYfiC2GISe4Yychebf3FfJqMtroF3cHp4b0Z6AOV2bdjheRo3q
u1iSaUeqGZ7+qcpidGIXav6/ttJqtliOx/e9/BpmlTSgVFFrqpclLomRoCsPnNrA
9Y5SVUxuJtMkX49iT6ZjChd2fnuiooC33XKv+QBuM/shYSM0FXopyFP418mj/yYR
gv4zAmukn/A76T4Zjf2qZYfZj4j7JgiWflqE3F4Lr0AHGtuImmhUdjPds0aXFWAK
UHcNowM9zgD184Trc5/iBeH5DuMSpYuCLuK6pdtuTi5b6fai4DuMrBJo1bpNuI7l
GcgplQW9U/fRpIArIhuB7AA/4FZj3KxRwcUGaJoD9qQjEMANnvI=
=0mMw
-----END PGP SIGNATURE-----
--=-=-=--

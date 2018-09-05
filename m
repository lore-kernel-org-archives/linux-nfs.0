Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56118 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727657AbeIFCnM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Sep 2018 22:43:12 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@hammerspace.com>,
        "aglo\@umich.edu" <aglo@umich.edu>
Date: Thu, 06 Sep 2018 08:10:37 +1000
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4.1 session reset needs to update ->rsize and ->wsize - how???
In-Reply-To: <b82396db1fa8c2b7141999f23f9dd60ae8fe8efe.camel@hammerspace.com>
References: <87r2i8vq10.fsf@notabene.neil.brown.name> <f7f84aced6ae709b1c66e1475e8d79927fa29132.camel@hammerspace.com> <87o9dcvmk6.fsf@notabene.neil.brown.name> <CAN-5tyG0DXosk0RUCM6E+pj-EmMWW5tuKfPg4HJChp9snvcQAQ@mail.gmail.com> <87lg8fveb9.fsf@notabene.neil.brown.name> <b82396db1fa8c2b7141999f23f9dd60ae8fe8efe.camel@hammerspace.com>
Message-ID: <87in3jvbmq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 05 2018, Trond Myklebust wrote:

> On Thu, 2018-09-06 at 07:12 +1000, NeilBrown wrote:
>> On Wed, Sep 05 2018, Olga Kornievskaia wrote:
>>=20
>> > On Tue, Sep 4, 2018 at 8:04 PM NeilBrown <neilb@suse.com> wrote:
>> > >=20
>> > > On Tue, Sep 04 2018, Trond Myklebust wrote:
>> > >=20
>> > > > On Wed, 2018-09-05 at 08:47 +1000, NeilBrown wrote:
>> > > > > With NFSv4.1, the server specifies max_rqst_sz and
>> > > > > max_resp_sz in the
>> > > > > reply to CREATE session.
>> > > > >=20
>> > > > > If the client finds it needs to call nfs4_reset_session(), it
>> > > > > might
>> > > > > get
>> > > > > smaller sizes back, so any pending read/writes would need to
>> > > > > be
>> > > > > resized.
>> > > > >=20
>> > > > > However, I cannot see how the retry handling for reads/writes
>> > > > > has any
>> > > > > chance to change the size.  It looks like a request is broken
>> > > > > up to
>> > > > > match the original ->rsize and ->wsize, then those individual
>> > > > > IO
>> > > > > requests can be retried, but the higher level request is
>> > > > > never
>> > > > > re-evaluated in light of a new size.
>> > > > >=20
>> > > > > Am I missing something, or is this not supported at present?
>> > > > > If it isn't supported, any suggestions on how best to handle
>> > > > > a
>> > > > > reduction of the rsize/wsize ??
>> > > > >=20
>> > > >=20
>> > > > Why would a sane server want to do this?
>> > >=20
>> > > Why would a sane protocol support it? :-)
>> > >=20
>> > > I have a network trace of SLE11-SP4 (3.0 based) talking to "a
>> > > NetApp
>> > > appliance".
>> > > It sends a 64K write and gets NFS4ERR_REQ_TOO_BIG.
>> > > It then closes the file (getting NFS4ERR_SEQ_MISORDERED even
>> > > though it
>> > > used a seq number 1 more than the WRITE request), and then
>> > > DESTROY_SESSION and CREATE_SESSION.
>> > > The CREATE_SESSION gets "max req size" of 33812 and "max resp
>> > > size" of
>> > > 33672.
>> > > It then opens the file again and retries the 64K write....
>> > >=20
>> > > I have a separate trace showing the initial mount where the sizes
>> > > are 71680
>> > > and 81920.
>> > >=20
>> > > I don't have a trace where it stops working, but reportedly
>> > > writes work
>> > > smoothly for some hours after a mount, but then suddenly stop
>> > > working.
>> > >=20
>> > > The CREATE_SESSION *call* requests I see have the small (32K)
>> > > sizes, but
>> > > presumably they are the result of a previous CREATE_SESSION reply
>> > > giving
>> > > a small value.
>> > >=20
>> > > I just had a thought.
>> > > If one session is shared by two "struct nfs_server" with
>> > > different
>> > > ->rsize or ->wsize, then the session might get set up with the
>> > > smaller
>> > > size, and the mount using the larger size will get confused.
>> > > In 3.0 (and even 3.10) nfs4_init_session() limits the requested
>> > > session
>> > > parameters to ->rsize and ->wsize.
>> > > That changed in 18aad3d552c7.
>> > >=20
>> > > Maybe I just need to remove that code from nfs4_init_session().
>> > > I'll give it a try.
>> > >=20
>> >=20
>> > Neil, does the code have this commit?
>> >=20
>> > commit 033853325fe3bdc70819a8b97915bd3bca41d3af
>> > Author: Olga Kornievskaia <kolga@netapp.com>
>> > Date:   Wed Mar 8 14:39:15 2017 -0500
>> >=20
>> >     NFSv4.1 respect server's max size in CREATE_SESSION
>> >=20
>> >     Currently client doesn't respect max sizes server returns in
>> > CREATE_SESSION.
>> >     nfs4_session_set_rwsize() gets called and server->rsize,
>> > server->wsize are 0
>> >     so they never get set to the sizes returned by the server.
>> >=20
>> >     Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> >     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>> >=20
>> > > Thanks,
>> > > NeilBrown
>>=20
>> Thanks for the suggestion.
>> The kernel doesn't have that patch, but I don't think it is relevant.
>> The ->rsize does have a suitable value - it isn't zero.
>> The problem is that the session limit appears to change, and the
>> client
>> doesn't adjust to the change.
>>=20
>> My current theory is that the client actually requested the change,
>> though on behalf of a different filesystem using the same session.
>>=20
>
> So perhaps the right thing to do then, is to advertise a session max
> response/reply size of NFS_MAX_FILE_IO_SIZE +
> max(nfs41_maxread_overhead,nfs41_maxwrite_overhead) and just expect the
> server negotiate that value down if it needs to?

Agreed - and that is exactly what Linux has done since about 3.11.
My customer is still on 3.0 which advertises ->[wr]size, and this change
wasn't obvious from the change logs so I didn't find it during my
initial investigation.
I've provided a patch and hope to get feedback in about a week.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAluQVGUACgkQOeye3VZi
gbmRCA/+NTD3J+Q0YL6yzTHFlctlL4FQWGGqZxtcq6JY1oWu7UXVeoCYGkdJd5hb
AqtqUJCn7cxCOjLRMZCvRAVmFFZW9onHwLC64XzvHZLhV6AoL5S1xaEWy7piIlyP
oRKvoXWi9fJ3jCP3br/2xya9IqvLgccaAMkRtpKHpVNBVUNNBp4DfDZj7fdt5o88
os5WD2QVWkpWDr3UoIDv6j6JimoFdiol4x9CiEPJRRiId33NliuNfvSpyisH5rXQ
l5DXW1PTEmp85eM4P5XJRYMmfYank6ZYpJFGXhz5SdzjdMLc7VmwvJ47T1fCKcor
XGW/3vyjmABI7P35PqJvPQxDK8m4G63ptfZ+3wOvQpxEHQvNR631cZ/K5wRvnkBz
W2BGUnYCeYpCzrD7u7rYybe29fxxbVJaQlApcpyvnR2IV5hbytAMO3VtBFkzSXr7
Cy6yD83qHmZph1/hIr6/ydaNlj1mUr2r3/GsjOC8DlgcQOCStqFumkJRFEWpKBJR
QSfV50+epILfdoRd9JCtgw4Mddsr8YHOMqjZS+8fEOrbX0ydqGSmoJV5m2LHk7XB
Dr7lF68VhKIB3iVHilipkiX9N3Arpwz/JL99WtQpI4OtfZ6F1lqOBh3rp3c6UdXT
08r/SZIxC+YwpgAtmPhdJL+s4eobhUwUpORow1xVh8lyhkQLaCU=
=wdti
-----END PGP SIGNATURE-----
--=-=-=--

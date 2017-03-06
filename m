Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51225 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752792AbdCFE0t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 5 Mar 2017 23:26:49 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "bfields\@fieldses.org" <bfields@fieldses.org>
Date: Mon, 06 Mar 2017 15:26:40 +1100
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 0/2] Fix up nfsd to enable NFSv4.x without NFSv4.0
In-Reply-To: <1488653739.34957.1.camel@primarydata.com>
References: <20170222233533.23845-1-trond.myklebust@primarydata.com> <87y3wxrcha.fsf@notabene.neil.brown.name> <1487811610.4863.10.camel@primarydata.com> <20170227230357.GA11912@fieldses.org> <87k287nv6r.fsf@notabene.neil.brown.name> <1488653739.34957.1.camel@primarydata.com>
Message-ID: <87o9xfjain.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Sat, Mar 04 2017, Trond Myklebust wrote:

> On Fri, 2017-03-03 at 09:57 +1100, NeilBrown wrote:
>> I guess I'm not entirely sure what Trond is trying to fix.
>> This bit:
>>=20
>> 1) When the user turns off all minor versions of NFSv4, then that
>> should
>> =C2=A0=C2=A0=C2=A0be equivalent to turning off NFSv4 support, and so whe=
n someone
>> tries
>> =C2=A0=C2=A0=C2=A0to mount, we should return RPC_PROG_MISMATCH.
>>=20
>> Makes perfect sense.=C2=A0=C2=A0But I'm not clear on why the format of t=
he
>> versions file needs to change.
>> Trond - what am I missing?
>>

Thanks for the details!!


>
> The main issue that worried me was one of predictability. What is
> supposed to happen when you type "echo +4"? One thing that I considered
> to be a regression, was that previously, I could expect that "echo +4"
> would at the very least turn on NFSv4 minor version 0, but with the
> change to semantics, it would only do so if nobody had typed "echo
> -4.0".

I don't think I would consider this as a regression.
Prior to

Commit: e35659f1b03c ("NFSD: correctly range-check v4.x minor version when =
setting versions.")

"echo -4.0" would result in an error.  After that patch it will result in
behaviour that you think is inconsistent.  While that might be a poor
design choice, I don't think it is a regression because it is not
(holistically) something that worked before and now works differently.

I agree that "echo +4" should do something sensible and predictable.  I
would like to suggest that it should enable all "supported" NFSv4.x minor
versions.  That is consistent with how rpc.nfsd uses it, and makes sense
to me. "echo -4" should disable all minor versions.

>
> An analogy would be putting 2 light switches in front of a light bulb,
> so that unless both switches are on, the bulb will not turn on.
> Actually, it is worse than that, because none of the bulbs turn on
> until you start up knfsd (so you can argue that there is a third switch
> in front of the other two).
> Why do we need this many levels of switches in a kernel interface? You
> should be able to achieve the same functionality by just turning on and
> off the individual minor versions. The right place for designing more
> complex interfaces would be userspace, and is exactly what the rpc.nfsd
> utility should be taking care of.

The "no regressions" rule can often lead to clunky interfaces.  It
certainly isn't ideal, but sometimes we need to live with it.
The right place to hide that clunkiness is in rpc.nfsd :-)

>
> Finally, there is the issue that the interface allowed situations where
> knfsd was advertising support for NFSv4 via rpcbind, but there were no
> minor versions enabled, and so you'd just get a confusing series of
> NFS4ERR_MINOR_VERSION_MISMATCH replies when attempting to mount. Why
> even advertise support in that case?

I agree with this.
If all minor versions are disabled, the major version should be disabled
as well.  If any minor versions are enabled, the major version must be
enabled too.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAli85QAACgkQOeye3VZi
gbkMQhAAwu4pZStPGa6CXmvRMzwQlufqWLyl2ban6kE6PDiEf4r+cNcrBBIJ6G/9
VxlAyqvQerEyS83/c4jJ5tWVX+WFsZ8ZrvwvknJI3jmrC/tBlmFQq7SmPeCQfN8z
q4aqwKvxnbITBy+e8xqj9MH946zAoFrruID8g5G9NMOSoC3MqPysp2S/SEcRaDN0
DKAmQjjhDf8BFTpfnfCWqjn8u1I29FFnBWvy+bOU2om0mjSgWFiM6fGcrx+fNu8f
HpetKqb4OOB2oD6aG5OIMjANYaVPv1TpWZ6jki2LspPUU8THkAreJEKGMBPgzpCL
Y0Kj5LWEXIWUj8v4EcmsoYP5hXtthlzLU4vCEuQOcL38ZFvbYPn0XNA0wbHLnGs5
N+FRiIZzbrjN8iJJ+dR+iEocYY+QDkFr0ukNupHqg2+Jx/hbODOAGJVWC1aLUTkj
p6q80Q2IK92/OtGElkiXsyvBCgYPfiMi5XAqW+l6smMJ8NwgfrT2Xu6zW5aLmU/y
c8+iJg9/saXtP1yOnVrnYEycC3HmYgjYau3khLI76tVepggrcVPbl1F0NFwXTJTF
oppBbk2arB4hPz3Zvzy/SRpeJuju4tOjSKHuPrFrQcyGQmLj01+zo8u69trvgQTY
XxEpS1QQ24RgJ+ZjhtOpy7apJCVewru/K5uvaPv2mEIfObdHt/c=
=SmnE
-----END PGP SIGNATURE-----
--=-=-=--

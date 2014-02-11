Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34745 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869AbaBKEvE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Feb 2014 23:51:04 -0500
Date: Tue, 11 Feb 2014 15:50:52 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140211155052.464aac7c@notabene.brown>
In-Reply-To: <52F93BA1.9060505@RedHat.com>
References: <20140130172451.7a354ce4@notabene.brown>
	<52F003A1.3060908@RedHat.com>
	<20140204093452.7b6d7c7d@notabene.brown>
	<20140204162052.GA5295@fieldses.org>
	<20140205140906.0b3ba9fd@notabene.brown>
	<1B2F95A4-8439-4274-A859-F33986D06824@oracle.com>
	<20140206122751.41b2fbf9@notabene.brown>
	<5630CFAD-1F31-4F87-AAA7-AEB06D3EC864@oracle.com>
	<20140206161917.GB14575@fieldses.org>
	<52F93BA1.9060505@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Mmcso.XpIEEWur7lR0wziVi"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Mmcso.XpIEEWur7lR0wziVi
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, 10 Feb 2014 15:50:41 -0500 Steve Dickson <SteveD@redhat.com> wrote:

> On 02/06/2014 11:19 AM, J. Bruce Fields wrote:
> > On Thu, Feb 06, 2014 at 11:09:58AM -0500, Chuck Lever wrote:
> >>
> >> On Feb 5, 2014, at 8:27 PM, NeilBrown <neilb@suse.de> wrote:
> >>> I certainly agree with making things simple.  If we can make a config=
uration
> >>> irrelevant, e.g. by gets nfsd to auto-tune the number of threads so t=
he
> >>> setting becomes pointless, then I've very happy to remove that sort of
> >>> configuration.  But if a configuration option actually means somethin=
g I
> >>> certainly don't want to remove it.
> >>>
> >>> So I'm leaning towards having "systemctl {un,}mask rpc-gssd" be the
> >>> configuration tool for rpc.gssd.
> >>
> >> I like that better than the =E2=80=9Coff-until-requested=E2=80=9D beha=
vior we have currently.  IMO folks who want to disable rpc.gssd will be in =
the increasing minority and the rest of the world will take scant notice of=
 the extra daemon, as long as we ensure it speaks only when necessary.
> >=20
> > I'd also prefer running the gssd's by default: one less (confusing) step
> > to set up kerberos, and I'm not seeing a realistic security risk.
> I'm not for starting daemon that are not needed or necessary. I
> just think that is a bad design.=20
> =20
> >=20
> > If we can easily provide a way to turn it off for people that want a
> > really stripped-down system for whatever reason, fine, let's provide
> > that.
> I'm thinking just the opposite... Have a way to easily (or even
> automatically) way to enabled NFS security....  when needed...
>=20
> Would it make it easier if we combined the gssd daemon? That goes
> both ways (server and client)... That way we could just enable=20
> nfs security and the daemon would started regardless on what side
> its on...=20
>=20
> steved.

By "combine" do you mean "rewrite the code so there is only one process" or
"have a systemd unit which starts both"?  The former seems like a lot of
pointless work and the later contradicts your stated preference for not
starting daemons that are not needed.

What do you think of the suggestion to start rpc.gssd when Wanted
if /etc/krb5.conf exists, and document that it can be disabled with

  systemctl mask rpc-gssd

(I like your idea of clearly documenting the important systemd units).
That way it is running when needed, probably not when not, and if you happen
to have kerberos installed but don't want rpc.gssd, it is easy to achieve
that.

NeilBrown

--Sig_/Mmcso.XpIEEWur7lR0wziVi
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvmsLDnsnt1WYoG5AQL7PQ//a78OBqqulPxWOLT3tgu4OmWfRux8Ugb3
iiKEf8Qj7nqvowMmWl1WjGUq7+6LDb2EcZvBFCFaRKc9PDRpquiMB1NvSFF0B0IV
qkGlu2j2rGgp8ZIgd+vX4pqI+EEbNF1ckR2LvaKvUmcN9xXZRNnNWt0pFfps736Z
vO7GIkjEnmA1f9MFddJwumirxhrxeNLmTWK0FpH1es62khjNjnv4F6ypD1Z2Lvy3
3reWhZdBAPR4T9rgLAuHZsUeAzJdxwgFafZxGEWF6BEPqj4YuBKDMG3vJdQkKjz1
CxRXkMKOnT+6gQwQh3fMQ6xsA8k7WNxVdRXJb7E7IdBO/KKigC7lUQ39i0Xsh7fP
PdyYKt+DNttr9x+uh1vOcDxAakbWFUJAYYtYSNldJtetbLAI21HyIkTlVAN8olsq
EHK9y77RubfaHKsVlBsijEtpIVAc+lBtr21g3vS3cHsoEJELbujbvj+u9e7MDemH
4I8ciJw7MDs4WSrjItAoKxoWs+egbJD3tbnpfuUpPaJVFIUR42ST5gZXpLb4KKyT
TkvqnqhfBHiSDVSZP2qs8mqNv9N+iUw9nO7cGr6z8wd2fkRnLRDhFMtogC7q98yW
1IUnNRd75C1n6pQR0uzMLogkeJq7HUycU8GPMwV7gD3+NRhPhqa6YolB4HESa7vN
50DuhkFfAR0=
=GIeJ
-----END PGP SIGNATURE-----

--Sig_/Mmcso.XpIEEWur7lR0wziVi--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59041 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750754AbcK3Bds (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Nov 2016 20:33:48 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 30 Nov 2016 12:33:39 +1100
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [PATCH 2/2] mount: RPC_PROGNOTREGISTERED should not be a permanent error
In-Reply-To: <db46b103-b5ac-998e-7bb6-8138f6a12711@RedHat.com>
References: <147157095612.26568.14161646901346011334.stgit@noble> <147157115640.26568.2934329194247787636.stgit@noble> <2a0955df-2fcd-05f1-9e6f-d8a549321177@RedHat.com> <87bmx7cezt.fsf@notabene.neil.brown.name> <34768ca3-0aa1-eb00-01c9-922e3bbcb51f@RedHat.com> <87poll93s7.fsf@notabene.neil.brown.name> <214253e5-5ef2-ae9a-bc57-20ed1c2f7e3a@RedHat.com> <87a8ci7yuo.fsf@notabene.neil.brown.name> <db46b103-b5ac-998e-7bb6-8138f6a12711@RedHat.com>
Message-ID: <87y4017nv0.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 30 2016, Steve Dickson wrote:

> On 11/29/2016 04:36 PM, NeilBrown wrote:
>>=20
>> Completely happy for distros to choose not to support it.  But there are
>> more users of Linux than we distro people hear from.
> Fair enough... So leave the code in, but off by default
> so it's not something that has to be tested.

Thanks for clarifying.  Sounds good to me.

>>=20
>> The EOPNOTSUPP commit fixed a real bug.  The bug would result in a mount
>> attempt failing when it should succeed.  Reverting that is not an
>> option.
> So the bug was that fact rpcbind was not up but the NFS server was?
> Or both were on there way up?

You could say that the bug was that rpcbind starts before the NFS server
has registered... but as the NFS server *cannot* register before rpcbind
starts, that would be a little harsh.

RPC_PROGNOTREGISTERED is a very close analogy to ECONNREFUSED.
They both say "The server process isn't listening (yet)".  One at the
TCP/IP level, one at the SUNRPC level.

If we started all daemons before enabling the network interface, and if
we could register all RPC services before rpcbind responds to external
requests, then these windows could be closed.  Unfortunately our
forefathers didn't have that foresight.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlg+LHMACgkQOeye3VZi
gblNoA//WyeUlBsCAoF/ir2VN2j+JRzsytsq3ed5z/klSW5H5JmaWm+K7jZxc5j8
XMKdxi6eTg5K+NGa+61c8SVXxtj6x2SovFHpgLjTZP/J9U3I2j5YGLnnVR0H/Tyr
hzFyPfW/5DSFeQZxQH+PV7wXrOICmzxp90BgbU5ECOjH9ZQ6zLG8s19JlnaWGnPJ
i/dlDJ1IbH7kw5B7rS2So4BeiXkpgY4ydyTd3pbvxmXaYg/8DsUqZD1gPsst56HZ
wAEQPQ9hwmr/PY9pMXKY25/mJ+u5pulZJkFGvfnQ0Vk7O3CMp05DzqyntyQnrnn2
3JVHLytDB9MnWIGN0IqK+22/J+bnnf/7GNXXZY+z5eRAUK8kXX8W3oT8gLBK8xBI
T8A8vlkXAUHjgPGd+dIqKSbBKlTRii8dlK5QPA+m6mIdBqDLZj7O9zYFtSmPXDHY
aMW/B2Z+4F2PomDrpkzQrmHpNkswoUWu06HB1U+fXoNEV2VY8yhi8MDi8n70ut8L
kj0iOKnMqfXp7PIsHgAiKoqpWXcC5tOChQrAGLF3xGInzFVS2fnDPisPdd1w238b
4O7As2BZuu0HnENlucMYwkpfU6sT29keWMO6wxOErpf8mCN9P5dsYeeWFidbuYTR
MRTxZn6EU8iohpmWXS39sOqv7zK4YBFvbucBpZsIU19QiikCOBQ=
=wXOG
-----END PGP SIGNATURE-----
--=-=-=--

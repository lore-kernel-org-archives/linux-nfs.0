Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33718 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752393AbbGKGPi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 11 Jul 2015 02:15:38 -0400
Message-ID: <55A0891F.4050105@redhat.com>
Date: Fri, 10 Jul 2015 23:10:23 -0400
From: Doug Ledford <dledford@redhat.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: Tom Talpey <tom@talpey.com>, "'Christoph Hellwig'" <hch@infradead.org>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <20150708190842.GB11740@obsidianresearch.com> <20150708203205.GA21847@infradead.org> <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <55A00754.4010009@redhat.com> <20150710205706.GA7883@obsidianresearch.com> <55A046EF.1060800@redhat.com> <20150710233417.GA8919@obsidianresearch.com>
In-Reply-To: <20150710233417.GA8919@obsidianresearch.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Xa9Os8cVnmuK7CgcLKWdRlWMdTxsiIBc0"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Xa9Os8cVnmuK7CgcLKWdRlWMdTxsiIBc0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/10/2015 07:34 PM, Jason Gunthorpe wrote:
> On Fri, Jul 10, 2015 at 06:27:59PM -0400, Doug Ledford wrote:
>=20
>> 1) An RDMA connection exists or can be created (TOE and iSCSI offload =
do
>> not do this, so something else would have to be listening and acceptin=
g
>> incoming RDMA connections)
>> 2) A global rkey exists (so it's not sufficient that any old RDMA app =
be
>> running, at least one app/ULP *must* create the global writable rkey)
>> 3) The QP of the RDMA connection belongs to the same PD as the global
>> rkey (so our attack surface is limited to the bad server app/ULP and t=
he
>> existence of this does not put other apps/ULPs at risk)
>> 4) For maximum damage, the global rkey must also belong to an app/ULP
>> with elevated privilege or direct memory access (kernel ULPs are prime=

>> targets, as a user app would have a mapped address space and the globa=
l
>> rkey in its domain would apply to it's process space, limiting the
>> damage that can be done).
>=20
> This list looks right to me.

Good, we're in agreement so far ;-)

>> Given all these requirements, I don't see this as a possibility.  In
>=20
> Hmm. So, if I put an iWarp card in a machine, boot any distro, and add
> something to /etc/exports ..
>=20
> Does the NFS RDMA kernel module load and start a listening QP?

That depends on the OS.

> If not, that actually sounds like a bug. What if a distro fixes that?

Red Hat requires that you enable NFSoRDMA.  But, your point is valid.
That goes back to my point about the update patch set being very verbose
about the dangers of this.  The very obvious kernel message is helpful
in this case.

>>> The clearest scary path I see is a server listening on a QP and using=

>>> IB_ACCESS_REMOTE_WRITE. That sure looks easy to exploit.
>>
>> This goes back to the trust domain.  For a server, you simply can't
>> allow untrusted clients.  Period.
>=20
> This feels like an antiquated security model. Most things these days
> are using in-band mutual auth and then switch to a trusted mode. Both
> NFS and iSCSI support that (kerberos,chap,etc), I assume that generic
> support extends to RDMA.
>=20
> If you use auth then trust as a security model, this rkey buisness is
> a problem, because you should not be vunerable to attack before
> authing.

Yes.  This is an antiquated security model.  There is a reason for that.
 It is easier to go simple to begin with and then add the extra layers
needed to keep things safe once you have the basics right.

>> access controls and connection filtering.  The app/ULP itself doesn't
>> even need to be filter aware as you can do the filtering in the TCP
>> stack on the primary listening socket using the netfilter tools.
>=20
> Does netfilter work for iWarp? I'm surprised to hear that.

iWARP requires a normal TCP socket to connect to, then the client must
initiate an RDMA transfer, then a new connection is opened for the RDMA
transfers.  Blocking the parent dst:port/*:* will prevent these
connections.  If you are referring to allowing an untrusted client in
TCP mode but blocking them in RDMA mode, that's more complex and
requires app/ULP support.

>> that goes back to the kernel warning I referred to in my previous emai=
l.
>>  Let users know what module is making this risky decision and it becom=
es
>> easy to filter any ports that module's services are listening on.
>=20
> That's fine, as long as the user is opting it this situation. If I'm
> not using RDMA but have an iWarp card, I should never see the
> message, even if RDMA support is autoloaded by my distro...

See above, an unexpected vulnerability caused by this model should
result in a very obvious kernel message.

>>> A client doing this.. It is alot harder to exploit.. iSER is client
>>> only, so less worrying. Can anyone else think of a way to attack the
>>> client?
>>
>> TCP injection only is all I've got.
>=20
> Black hat server can also do it, and since it is possible before auth
> it is doable without the server auth credential.

Black hat server is beyond the scope of this discussion.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--Xa9Os8cVnmuK7CgcLKWdRlWMdTxsiIBc0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJVoIkfAAoJELgmozMOVy/dyZIP/3iCFSl/1pbQ5+QswIs2ZRCw
4PQOu1CP2FRyH86i6qBVqSZRv1l6ElqMJZ8jox5kzMpcwqEFwqiK7CmkLFAxaqXa
roXamO027ujwyMiPaAlhH5OI/wMJciEyufwVN1aAmbFdWvbucUoZqQyujvGx7V6z
0TqZxyzHF/Bvtvt6I1bvwGU3Z70eRcPu0WBG2Q3K5myjQjma0pjR00sH+KoI7GGj
ZQigvenv8V46bGYyU9A20HhuZ+9Ma+QFtaIig0Ku2v5gdpP61yb+Y1s3ZnwllKX2
QzDP0LuwifVYCFAGWElU8wuE0Zhwc2s45kTdFmvEn6nejYVX+ELmPaOws4uplB7I
3DHCw2qByzFKJFGN1viyBv/h5njrHP+6hPqlZL5sj1TAVmr2p7kvKNaoFIQIVzv4
kqpuShEC6Bx0iLkKYRRkZanPgz8sdf4c3Erx3IE6z7qNr5MtEvi9RvhaxyoCO/LB
dZQQMryYVXpAwmqAwJE8BDfkOgTSHMfCZxhWUKnvcbv2lEDI1whqIIk/ebGezGH2
ssK9baudFAIFsx2vNSdJPL1sWZLL2eUI4rzg7KYr7qB8OLHQN7pEZjFKjTNDO4Jr
drQ6pcowKF736NfwNqCJ+M9ekrvHexJeKmUwVsTSeWul32zmA1xZswaemIMUyFeE
PBLPWI7DLMqL7F8tBaz6
=LkVg
-----END PGP SIGNATURE-----

--Xa9Os8cVnmuK7CgcLKWdRlWMdTxsiIBc0--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47360 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047AbbGJW2F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 18:28:05 -0400
Message-ID: <55A046EF.1060800@redhat.com>
Date: Fri, 10 Jul 2015 18:27:59 -0400
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
References: <20150707213628.GA5661@obsidianresearch.com> <559CD174.4040901@dev.mellanox.co.il> <20150708190842.GB11740@obsidianresearch.com> <20150708203205.GA21847@infradead.org> <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <55A00754.4010009@redhat.com> <20150710205706.GA7883@obsidianresearch.com>
In-Reply-To: <20150710205706.GA7883@obsidianresearch.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="nvO2NngwSgKlJhF2t5Qn3F2CSmL2kDVEO"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--nvO2NngwSgKlJhF2t5Qn3F2CSmL2kDVEO
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/10/2015 04:57 PM, Jason Gunthorpe wrote:
> On Fri, Jul 10, 2015 at 01:56:36PM -0400, Doug Ledford wrote:
>=20
>> Are there security issues?  Yes.  Are we going to solve them in this
>> patch set?  No.  Especially since those security issues extend beyond
>> iSER + iWARP.
>=20
> I think my biggest concern is we don't inadvertently open a security
> hole on a machine that just happens to have an iwarp card installed,
> but has nothing to do with HPC.

Given the number of Chelsio cards utilized in things like TCP Offload
and iSCSI offload situations versus HPC, this isn't an unreasonable
thing to consider.  However, the attack vector is limited to a situation
where all of the below are true:

1) An RDMA connection exists or can be created (TOE and iSCSI offload do
not do this, so something else would have to be listening and accepting
incoming RDMA connections)
2) A global rkey exists (so it's not sufficient that any old RDMA app be
running, at least one app/ULP *must* create the global writable rkey)
3) The QP of the RDMA connection belongs to the same PD as the global
rkey (so our attack surface is limited to the bad server app/ULP and the
existence of this does not put other apps/ULPs at risk)
4) For maximum damage, the global rkey must also belong to an app/ULP
with elevated privilege or direct memory access (kernel ULPs are prime
targets, as a user app would have a mapped address space and the global
rkey in its domain would apply to it's process space, limiting the
damage that can be done).

Given all these requirements, I don't see this as a possibility.  In
order to be at risk, there *must* be a listening app/ULP, and we should
be able to print out a nice, dire warning in dmesg if that app/ULP opens
itself up in this way.

> The clearest scary path I see is a server listening on a QP and using
> IB_ACCESS_REMOTE_WRITE. That sure looks easy to exploit.

This goes back to the trust domain.  For a server, you simply can't
allow untrusted clients.  Period.  But that's easy enough to do with
access controls and connection filtering.  The app/ULP itself doesn't
even need to be filter aware as you can do the filtering in the TCP
stack on the primary listening socket using the netfilter tools.  And
that goes back to the kernel warning I referred to in my previous email.
 Let users know what module is making this risky decision and it becomes
easy to filter any ports that module's services are listening on.

> A client doing this.. It is alot harder to exploit.. iSER is client
> only, so less worrying. Can anyone else think of a way to attack the
> client?

TCP injection only is all I've got.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--nvO2NngwSgKlJhF2t5Qn3F2CSmL2kDVEO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJVoEbvAAoJELgmozMOVy/dQyIQAKFhdyUEVkXwTCPbUv7czjZB
uhi3QHn/mqFieI06mnjEUyEHh5y4xDj+Fq+5GUDMQ7ufGUJxqLa5hw823OVljqTo
avi/L/2/RJWkX7IyovQc+yZfUJwWJsO6GGW10AMHkxT+eeHfEZKNCtcrYd8/ai/j
W+VVRm0JgLnsQHxwfbOqq392mrMLaqNXGB/G5Yo4/iT4b2Q0M4Fq+NkvRzTJIhpJ
1V9IP3v93FU4PBT0wwZQuYxiy+vCM3YCKg2AxjbaH/C4cQPmyCuhmwmAM4wSygsq
e0qaIAOlKUV7/pjXstZt2YFOC4OD8qpQ9pTzYTBJ8Cj/p9B2HhLQlxU+evTXUrV+
A+uEBY1exeeFtDBecdHQ9jxxDclvinmtykSTYETa+RZPON56NPxEPLI1mlxoK/1S
TUGuYgvG2556q9V/rhTO4cZ4YWfDHtw3dlqNI3EXDbxmzv2krPz/syci8FXoZqFE
jotCb7OUG0X2xl7AZQeQ7tBluIDBO0tuiViVqLh6oPsmI+BvgPpOBL6eAzOIEkRZ
GUACU0z4RPhfs1FeRYlK4Nvt3RpY0B1Se6KKnBqpWlBrZfx+oLTc9vajfHWhkijl
47Ify7/hnX84Uv9jzJqPSI1T0/RGMTm/PEJqGMmepjEzlKQjH4YaYlvXjuSGTost
5wtiYkU/YIVOaTOigaaG
=SMDO
-----END PGP SIGNATURE-----

--nvO2NngwSgKlJhF2t5Qn3F2CSmL2kDVEO--

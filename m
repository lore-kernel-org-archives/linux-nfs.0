Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45744 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751593AbdG0K6n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 27 Jul 2017 06:58:43 -0400
Date: Thu, 27 Jul 2017 11:58:35 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
Message-ID: <20170727105835.GF10129@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-6-stefanha@redhat.com>
 <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
 <87wp7lvst9.fsf@notabene.neil.brown.name>
 <87tw2ox4st.fsf@notabene.neil.brown.name>
 <20170725100513.GA5073@stefanha-x1.localdomain>
 <87eft2wjfy.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="RE3pQJLXZi4fr8Xo"
In-Reply-To: <87eft2wjfy.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--RE3pQJLXZi4fr8Xo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 27, 2017 at 03:13:53PM +1000, NeilBrown wrote:
> On Tue, Jul 25 2017, Stefan Hajnoczi wrote:
> > On Fri, Jul 07, 2017 at 02:13:38PM +1000, NeilBrown wrote:
> >> On Fri, Jul 07 2017, NeilBrown wrote:
> >> > On Fri, Jun 30 2017, Chuck Lever wrote:
> >> I don't think the server can filter connections based on which interfa=
ce
> >> a link-local address came from.  If that was a problem that someone
> >> wanted to be fixed, I'm sure we can fix it.
> >>=20
> >> If you need to be sure that clients don't fake their IPv6 address, I'm
> >> sure netfilter is up to the task.
> >
> > Yes, it's common to prevent spoofing on the host using netfilter and I
> > think it wouldn't be a problem.
> >
> >>  . Creates network interfaces on host that must be managed
> >>=20
> >> What vsock does is effectively create a hidden interface on the host t=
hat only the
> >> kernel knows about and so the sysadmin cannot break it.  The only
> >> difference between this and an explicit interface on the host is that
> >> the latter requires a competent sysadmin.
> >>=20
> >> If you have other reasons for preferring the use of vsock for NFS, I'd=
 be
> >> happy to hear them.  So far I'm not convinced.
> >
> > Before working on AF_VSOCK I originally proposed adding dedicated
> > network interfaces to guests, similar to what you've suggested, but
> > there was resistance for additional reasons that weren't covered in the
> > presentation:
>=20
> I would like to suggest that this is critical information for
> understanding the design rationale for AF_VSOCK and should be easily
> found from http://wiki.qemu.org/Features/VirtioVsock

Thanks, I have updated the wiki.

> To achieve zero-config, I think link-local addresses are by far the best
> answer.  To achieve isolation, some targeted filtering seems like the
> best approach.
>=20
> If you really want traffic between guest and host to go over a vsock,
> then some sort of packet redirection should be possible.

The issue we seem to hit with designs using AF_INET and network
interfaces is that they cannot meet the "it must avoid invasive
configuration changes, especially inside the guest" requirement.  It's
very hard to autoconfigure in a way that doesn't conflict with the
user's network configuration inside the guest.

One thought about solving the interface naming problem: if the dedicated
NIC uses a well-known OUI dedicated for this purpose then udev could
assign a persistent name (e.g. "virtguestif").  This gets us one step
closer to non-invasive automatic configuration.

Stefan

--RE3pQJLXZi4fr8Xo
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZecdbAAoJEJykq7OBq3PIqOYIAJFoYfVOIsISAA0s/crj9pEk
zWxPK9e1h01KSsUzpVgPEtHzs4ygkUPAg9fe7uPF68gsukf1BaaqvpezpcwHLW+3
+YnVgRjJKc5SpiAU6K5QpLUKClfoaOFt5wv6d1VcEMRUaVr2/fj4tJhdkewUTzM6
bQi+4uNi59VsQiK5sfBZ1m4oSJ1Yw4MgJfpzlfbAqHL4/G8GwbfNRhKNk67UGU6a
38+XC8OfMcQsJXTxCJwTFux1KdoyVNP+QqV+bES+GRo6Fr/SS2pha+YYC5awn9zb
G1s/2e6NwzVcCAiSmHZXwxEtAI/E0dPgsNu5W2k9jZAH0zTGpY4rI+Gur9lKoXI=
=1B4w
-----END PGP SIGNATURE-----

--RE3pQJLXZi4fr8Xo--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57051 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751551AbdG0XLe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 27 Jul 2017 19:11:34 -0400
From: NeilBrown <neilb@suse.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Date: Fri, 28 Jul 2017 09:11:22 +1000
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
In-Reply-To: <20170727105835.GF10129@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com> <20170630132120.31578-6-stefanha@redhat.com> <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com> <87wp7lvst9.fsf@notabene.neil.brown.name> <87tw2ox4st.fsf@notabene.neil.brown.name> <20170725100513.GA5073@stefanha-x1.localdomain> <87eft2wjfy.fsf@notabene.neil.brown.name> <20170727105835.GF10129@stefanha-x1.localdomain>
Message-ID: <8760edwk4l.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 27 2017, Stefan Hajnoczi wrote:

> On Thu, Jul 27, 2017 at 03:13:53PM +1000, NeilBrown wrote:
>> On Tue, Jul 25 2017, Stefan Hajnoczi wrote:
>> > On Fri, Jul 07, 2017 at 02:13:38PM +1000, NeilBrown wrote:
>> >> On Fri, Jul 07 2017, NeilBrown wrote:
>> >> > On Fri, Jun 30 2017, Chuck Lever wrote:
>> >> I don't think the server can filter connections based on which interf=
ace
>> >> a link-local address came from.  If that was a problem that someone
>> >> wanted to be fixed, I'm sure we can fix it.
>> >>=20
>> >> If you need to be sure that clients don't fake their IPv6 address, I'm
>> >> sure netfilter is up to the task.
>> >
>> > Yes, it's common to prevent spoofing on the host using netfilter and I
>> > think it wouldn't be a problem.
>> >
>> >>  . Creates network interfaces on host that must be managed
>> >>=20
>> >> What vsock does is effectively create a hidden interface on the host =
that only the
>> >> kernel knows about and so the sysadmin cannot break it.  The only
>> >> difference between this and an explicit interface on the host is that
>> >> the latter requires a competent sysadmin.
>> >>=20
>> >> If you have other reasons for preferring the use of vsock for NFS, I'=
d be
>> >> happy to hear them.  So far I'm not convinced.
>> >
>> > Before working on AF_VSOCK I originally proposed adding dedicated
>> > network interfaces to guests, similar to what you've suggested, but
>> > there was resistance for additional reasons that weren't covered in the
>> > presentation:
>>=20
>> I would like to suggest that this is critical information for
>> understanding the design rationale for AF_VSOCK and should be easily
>> found from http://wiki.qemu.org/Features/VirtioVsock
>
> Thanks, I have updated the wiki.

Thanks.  How this one:

  Can be used with VMs that have no network interfaces

is really crying out for some sort of justification.

And given that ethernet/tcpip  must be some of the most attacked (and
hence hardened" code in Linux, some explanation of why it is thought
that they expose more of an attack surface than some brand new code,
might be helpful.

>
>> To achieve zero-config, I think link-local addresses are by far the best
>> answer.  To achieve isolation, some targeted filtering seems like the
>> best approach.
>>=20
>> If you really want traffic between guest and host to go over a vsock,
>> then some sort of packet redirection should be possible.
>
> The issue we seem to hit with designs using AF_INET and network
> interfaces is that they cannot meet the "it must avoid invasive
> configuration changes, especially inside the guest" requirement.  It's
> very hard to autoconfigure in a way that doesn't conflict with the
> user's network configuration inside the guest.
>
> One thought about solving the interface naming problem: if the dedicated
> NIC uses a well-known OUI dedicated for this purpose then udev could
> assign a persistent name (e.g. "virtguestif").  This gets us one step
> closer to non-invasive automatic configuration.

I think this is well worth pursuing.  As you say, an OUI allows the
guest to reliably detect the right interface to use a link-local address
on.

Thanks,
NeilBrown


>
> Stefan

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAll6cxwACgkQOeye3VZi
gbnOlBAAmFqgnHgF3Xo41FzBZxjk7PD91mCdWGZY5BhBW2M99+mCDuqnIOGR0ZyO
2vWR6K+XboL5Ej7v/gBYGmLIFP/EegOrC1LD6OnoxanHtuLV9ErgZ4xkJG3N7FHC
KSfgtIaKCrzsoJeJVqOkRL/bsc1YKRNxfvOCr2FsPhGUBbPln/i+WgIBZ+KannNS
Fbhug0Lp5k7fLMA2MIj3CmSzoKYlUfHr+We/1SBpdyGWW6Uy02k+tCnbely3vxiF
K/OS2mBFoJcjg2DQe+OyaUkLShaG9uUyIYcOU6DB4vcZfBMCdvl/Mt9iG3/It6Be
T/sXCXodjdClubt/ooIIEVFo/QpbjPFICEg5H0N7DXIQDfwQx1sJj42zjQtY6nhy
1MoysVxiy0BN3PINEn5SGoxKJLiIE74FcY/XUgpPsX9BkIqm2wmgyajPbDRzenuT
8gY7uq1tfEftHZWQY4PWFlYDCVZU1vS6SzYigp30HgjdJ0JWvURk5pZlIruPq8DR
m4hOQt1zbIZnX4sWFZgyxdNVfVfbA+1M2wCB5viBm7vDdAWkEJ9+7ckxIJbpawrC
cQGRSemosjdbvU7nk2ih7klZHtMF2xygYMpL8dEJywAaIvRbga0ATmMBCq+3pqcx
WRUvUu8G0B3Erv/yDV84yIIEqQcI2jIbqdduucJTjNsnMTKES3E=
=uNR0
-----END PGP SIGNATURE-----
--=-=-=--

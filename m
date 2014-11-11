Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54007 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323AbaKKXAT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Nov 2014 18:00:19 -0500
Date: Wed, 12 Nov 2014 10:00:11 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: bstroesser@ts.fujitsu.com, linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
Message-ID: <20141112100011.74b6549f@notabene.brown>
In-Reply-To: <5462545F.4010706@RedHat.com>
References: <d6437a$6ag11f@dgate10u.abg.fsc.net>
	<5462545F.4010706@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/c3ehowliBZ2Uc59OwxDokwG"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/c3ehowliBZ2Uc59OwxDokwG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 11 Nov 2014 13:24:31 -0500 Steve Dickson <SteveD@redhat.com> wrote:

> Hello,
>=20
> On 11/05/2014 03:21 PM, bstroesser@ts.fujitsu.com wrote:
> > Hello,
> >=20
> > I'm sending a small set of 3 patches for a problem, that I have
> > reported a few weeks ago.
> > rpc.mountd can be blocked by a bad client, that sends lots of
> > RPC requests, but never reads the replies from the socket either
> > intentionally or e.g. caused by a wrong configured MTU.
> >=20
> > While looking for a possible solution, I found another weakness
> > in rpc.mountd if it is used "multithreaded" (-t nn).
> >=20
> > The first two patches fix that weakness in the case of !HAVE_LIBTIRPC
> > and HAVE_LIBTIRPC.
> > The third patch more a kind of suggestion how the main problem could
> > be fixed. I don't know whether we can set MAXREC without causing
> > new troubles. When this patch is used, a  further patch for libtirpc
> > also should be used. You can find it here:
> >     http://sourceforge.net/p/libtirpc/mailman/libtirpc-devel/?viewmonth=
=3D201409
>=20
> Over the weekend I took a good hard look at these 3 patches and
> the one for libtirpc with the reproducer Bodo supplied me.
> (Bodo, thanks all the help getting things set up!).
>=20
> I agree with the libtirpc patch so its been committed,
> but other three made me nervous so I wanted to take a=20
> good hard look at them. (Neil's question, "do we really
> what to make these non-block" haunted me ;-) ).
>=20
> It turns out, at least in my setup, these patches do not
> and can not stop the mountd DOS that Bodo's reproducer
> creates.=20
>=20
> Here is why they do not work:=20
>=20
> The fd that the write() is getting hung on, is not be created=20
> by the 3 nfs_svc_create() calls in mountd:main(). Its
> being created by the accept() when the tcp connection
> is created (via SVC_RECV()), so making those fds coming=20
> out of the nfs_svc_create() non-blocking does nothing.=20

Just to add to what Bodo replied:

SVC_RECV is a macro which calls .xp_recv, which in the TCP listen
case is rendezvous_request.

rendezvous_request does the accept:

        if ((sock =3D accept(xprt->xp_fd, (struct sockaddr *)(void *)&addr,
            &len)) < 0) {

and then
        if (cd->maxrec !=3D 0) {
                flags =3D fcntl(sock, F_GETFL, 0);
                if (flags  =3D=3D -1)
                        return (FALSE);
                if (fcntl(sock, F_SETFL, flags | O_NONBLOCK) =3D=3D -1)
                        return (FALSE);
 =20
so if cd->maxrec is not zero, O_NONBLOCK get set.

It gets set through an SVC_CONTROL -> xp_control -> svc_vc_rendezvous_contr=
ol

call, which no-one ever makes, and it initialised to __svc_maxrec, which is
set by the rpc_control() call that Bodo mentions.
So providing rpc_control is called before the service is created, it should
work fine.

I wonder why it didn't work for you...


Thanks,
NeilBrown



>=20
> Here is the hang can't be stop (for now):
>=20
> Here is the stack:
> Stack trace of thread 4150:
> #0  0x00000036816f0e90 write (libc.so.6)
> #1  0x00007fd53837da6d write_vc (libtirpc.so.1)
> #2  0x00007fd53838103f flush_out (libtirpc.so.1)
> #3  0x00007fd53837dd81 svc_vc_reply (libtirpc.so.1)
> #4  0x00007fd53837b096 svcerr_noprog (libtirpc.so.1)
> #5  0x00007fd53837b360 svc_getreq_common (libtirpc.so.1)
> #6  0x00000000004086d9 my_svc_getreqset (mountd)
> #7  0x0000000000403d80 main (mountd)
> #8  0x000000368161ffe0 __libc_start_main (libc.so.6)
> #9  0x00000000004040f5 _start (mountd)
>=20
> The fd that created by the SVC_RECV() is never=20
> given back to the app (in case mountd) to make
> it non-blocking. Its used in the error path
> where it get hung up in the write(). The
> app has no control over that.=20
>=20
> Now I definitely see a problem, but these
> patches (with the exception of the libtirpc
> patch) don't address the problem I am seeing.
>=20
> So unless I'm not seeing something, I'm not in
> favor of taking these 3 patches.
>=20
> thoughts?
>=20
> steved.


--Sig_/c3ehowliBZ2Uc59OwxDokwG
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVGKU+znsnt1WYoG5AQJQ4g//RaPlQaQvsq1MKEKOf6Zc5q4oplOn+b42
tB7oHyWebpZcyzGD5Wm6hGVg0Rp551oxyzpQ7JDLnfUQXK9YwLjfrvBPx8ywwgY5
RmZdfvLz6cfin5EuSD/5iCgOvOLQB8bV73HDLAiLEhYsjbb7pyVkUMe4OLYFZp2k
gM1m17ru0fUjycF4YEkIY03Lp4FmbbDuSvzXeqHn6OYbpQtFW7guTuwhWXVhJWF/
faaSWb7uoa3LL0SGvBpjIiVwnxjY774XDiSPi2qoS9VkOvZWT3kPFzQAEUEEXNSU
cN/DlmoaVtBRRz+W3HraDHz0kcCLTp2X8DSifou960j+7Nq0D8SkhtvvAjAtR6UD
cnYsnW7aQ3uZYqxGLa6sgBgr3x6ME29vyXbvu4cvE57yOa1plWU95Y2kgN3JfAc3
1uM3XHzl8Rui+1mXU5qj6xWldKQL2mompt9VgKLdk2jazQAF8iwoKn/u8DP7ly/B
bNcoyqLsMG4W0enIMHOzKQJPGtQYrR56JvsEr4bnWD8Ymi5wbm+b2NlZKtt5pi/z
XFCeyyryqRBvrM4U/ndOSRqHmmhbqFs1dXSfIa4vp1idnwNA9cJe611mZSrT4Bw3
O4wX+mukG0021HiYn+V5f5Dxg5/XCEpi3a5SKlnJFJI3pBC+whq0Xb4HgvBNbQOC
f6MDFRcQgPo=
=cFzp
-----END PGP SIGNATURE-----

--Sig_/c3ehowliBZ2Uc59OwxDokwG--

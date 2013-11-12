Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39893 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751538Ab3KLFLt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 00:11:49 -0500
Date: Tue, 12 Nov 2013 16:11:35 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
Message-ID: <20131112161135.25a487da@notabene.brown>
In-Reply-To: <E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com>
References: <1384037221-7224-1-git-send-email-steved@redhat.com>
	<E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com>
	<52811CBB.3070204@RedHat.com>
	<E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com>
	<5281290B.6000201@RedHat.com>
	<E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/k22ah18bnD5OBE=hwfsUBq8"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/k22ah18bnD5OBE=hwfsUBq8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, 11 Nov 2013 15:33:14 -0500 Chuck Lever <chuck.lever@oracle.com> wro=
te:

>=20
> On Nov 11, 2013, at 1:59 PM, Steve Dickson <SteveD@redhat.com> wrote:
>=20
> > On 11/11/13 13:30, Chuck Lever wrote:
> >>=20
> >> On Nov 11, 2013, at 1:06 PM, Steve Dickson <SteveD@redhat.com> wrote:
> >>=20
> >>>=20
> >>>=20
> >>> On 09/11/13 18:12, Myklebust, Trond wrote:
> >>>> One alternative to the above scheme, which I believe that I=E2=80=99=
ve=20
> >>>> suggested before, is to have a permanent entry in rpc_pipefs=20
> >>>> that rpc.gssd can open and that the kernel can use to detect=20
> >>>> that it is running. If we make it /var/lib/nfs/rpc_pipefs/gssd/clnt0=
0/gssd,=20
> >>>> then AFAICS we don=E2=80=99t need to change nfs-utils at all, since =
all newer=20
> >>>> versions of rpc.gssd will try to open for read anything of the form=
=20
> >>>> /var/lib/nfs/rpc_pipefs/*/clntXX/gssd...
> >>>=20
> >>> After further review I am going going have to disagree with you on th=
is.
> >>> Since all the context is cached on the initial mount the kernel
> >>> should be using the call_usermodehelper() to call up to rpc.gssd=20
> >>> to get the context, which means we could put this upcall noise=20
> >>> to bed... forever! :-)
> >>=20
> >> Ask Al Viro for his comments on whether the kernel should start=20
> >> gssd (either a daemon or a script).  Hint: wear your kevlar underpants.
> > I was thinking gssd would become a the gssd-cmd command... Al does not
> > like the call_usermodehelper() interface?
>=20
> He doesn't have a problem with call_usermodehelper() in general.  However=
, the kernel cannot guarantee security if it has to run a fixed command lin=
e.  Go ask him to explain.
>=20
>=20
> >=20
> >>=20
> >> Have you tried Trond's approach yet?
> > Looking into it... But nothing is trivial in that code...=20
> >=20
> >>=20
> >>> I realize this is not going happen overnight, so I would still
> >>> like to propose my  nfs4_secure_mounts bool patch as bridge
> >>> to the new call_usermodehelper()  since its the cleanest=20
> >>> solution so far...=20
> >>>=20
> >>> Thoughts?
> >>=20
> >> We have workarounds already that work on every kernel since 3.8.
> >>=20
> > The one that logs 5 to 20 lines (depending on thins are setup or not)
> > per mount? That does work in some environments but no all. ;-)
>=20
> When does running rpc.gssd not work?

Oohh ooh.. Pick me.  Pick me!! I can answer that one.

Running rpc.gssd does not work if you are mounting a filesystem using the IP
address of the server and that IP address doesn't have a matching hostname
anywhere that can be found:

In a newly creating minimal kvm install without rpc.gssd running,
   mount 10.0.2.2:/home /mnt

sleeps for 15 seconds then succeeds.
If I start rpc.gssd, then the same command takes forever.

strace of rpc.gssd shows that it complains about not being able to resolve
the host name and "ERROR: failed to read service info".  Then it keeps the
pipes open but never sends any message on them, so the kernel just keeps on
waiting.

If I change "fail_keep_client" to "fail_destroy_client", then it closes the
pipe and we get the 15 second timeout back.
If I change  NI_NAMEREQD to 0, then the mount completes instantly.  (of cou=
rse
that make serious compromise security so it was just for testing).
(Adding an entry to /etc/hosts also gives instant success).

I'm hoping that someone who understands this code will suggest something
clever so I don't have to dig through all of it ;-)

NeilBrown

--Sig_/k22ah18bnD5OBE=hwfsUBq8
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUoG4hznsnt1WYoG5AQJN3A/9GMuHCp9PxjtnIWzj59oPS2LRKAc2fPGI
3LzwNg0sGQXGRgjxXofdNzG0LlaHyQLmCBLkEtuz7/i5A+QAAkqAMh/rt8zSDsq6
b1s+fyXLADLmd2M0kOS+OeVzdd32QIZdjTvNVa4aesUnsuzCxV4DrrpNDObOMTk+
4qeeYd8LAey77VMu8QyJqX1K5AILoz2HywenYLj/yR+peSr1RvGKtpknptbn3phD
pLxOz+5dirrC+HXxr4lZ7kIPfJPkP9ENgnCtYa44BbWoRJOWzMlJQtsViq9pYhBC
xYjrq9asLeRKFYy72Oos6IE+RaDGJsS5UGEDNcw9O/da6pW2ridCB3CeoO2l9Gob
ivhn2dRv4EZcUjQLZit1EsHSbsKsP+yFxRIluRU9FLsXHz9inJHdbORaCj8tPWWD
rT2ZyP/yKBW+sHkllAfR1dlsOSxZStdvE4g6BcShRNVFRFXSmtvKOhh0yckVuw9k
tOZGKCa0F8mvhzR0EeU1YH+LjkyXPA25JtJnCKx82WALkGQdZfrbQRpoLrNt2ju2
cedhP4b+UJSecPO2SUsDf+IzhRNIPqENwkKWkIOkx3834AyBQ7UtQxHK23KQOy+I
NxleFstIAWHoLG4JihpyK25FjvcP/Ke7IrNvcKfSTtNZSjy5TWnBZOKedQQPZSEI
Bzc1WBE+8LM=
=WMv8
-----END PGP SIGNATURE-----

--Sig_/k22ah18bnD5OBE=hwfsUBq8--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55218 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753178Ab3KMAYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 19:24:00 -0500
Date: Wed, 13 Nov 2013 11:23:46 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Charles Edward Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
Message-ID: <20131113112346.3f5f3bd0@notabene.brown>
In-Reply-To: <20131112161634.GC15060@fieldses.org>
References: <1384037221-7224-1-git-send-email-steved@redhat.com>
	<E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com>
	<52811CBB.3070204@RedHat.com>
	<E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com>
	<5281290B.6000201@RedHat.com>
	<E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com>
	<20131112161135.25a487da@notabene.brown>
	<F58540AB-00BE-4AC5-B823-7260F30F8D58@netapp.com>
	<20131112161634.GC15060@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/xlPCVnJmyEZv9ETL/avnday"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/xlPCVnJmyEZv9ETL/avnday
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Tue, 12 Nov 2013 11:16:34 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Nov 12, 2013 at 05:29:46AM +0000, Myklebust, Trond wrote:
> >=20
> > On Nov 12, 2013, at 0:11, NeilBrown <neilb@suse.de> wrote:
> >=20
> > > On Mon, 11 Nov 2013 15:33:14 -0500 Chuck Lever <chuck.lever@oracle.co=
m> wrote:
> > >=20
> > >>=20
> > >> On Nov 11, 2013, at 1:59 PM, Steve Dickson <SteveD@redhat.com> wrote:
> > >>=20
> > >>> On 11/11/13 13:30, Chuck Lever wrote:
> > >>>>=20
> > >>>> On Nov 11, 2013, at 1:06 PM, Steve Dickson <SteveD@redhat.com> wro=
te:
> > >>>>=20
> > >>>>>=20
> > >>>>>=20
> > >>>>> On 09/11/13 18:12, Myklebust, Trond wrote:
> > >>>>>> One alternative to the above scheme, which I believe that I=E2=
=80=99ve=20
> > >>>>>> suggested before, is to have a permanent entry in rpc_pipefs=20
> > >>>>>> that rpc.gssd can open and that the kernel can use to detect=20
> > >>>>>> that it is running. If we make it /var/lib/nfs/rpc_pipefs/gssd/c=
lnt00/gssd,=20
> > >>>>>> then AFAICS we don=E2=80=99t need to change nfs-utils at all, si=
nce all newer=20
> > >>>>>> versions of rpc.gssd will try to open for read anything of the f=
orm=20
> > >>>>>> /var/lib/nfs/rpc_pipefs/*/clntXX/gssd...
> > >>>>>=20
> > >>>>> After further review I am going going have to disagree with you o=
n this.
> > >>>>> Since all the context is cached on the initial mount the kernel
> > >>>>> should be using the call_usermodehelper() to call up to rpc.gssd=
=20
> > >>>>> to get the context, which means we could put this upcall noise=20
> > >>>>> to bed... forever! :-)
> > >>>>=20
> > >>>> Ask Al Viro for his comments on whether the kernel should start=20
> > >>>> gssd (either a daemon or a script).  Hint: wear your kevlar underp=
ants.
> > >>> I was thinking gssd would become a the gssd-cmd command... Al does =
not
> > >>> like the call_usermodehelper() interface?
> > >>=20
> > >> He doesn't have a problem with call_usermodehelper() in general.  Ho=
wever, the kernel cannot guarantee security if it has to run a fixed comman=
d line.  Go ask him to explain.
> > >>=20
> > >>=20
> > >>>=20
> > >>>>=20
> > >>>> Have you tried Trond's approach yet?
> > >>> Looking into it... But nothing is trivial in that code...=20
> > >>>=20
> > >>>>=20
> > >>>>> I realize this is not going happen overnight, so I would still
> > >>>>> like to propose my  nfs4_secure_mounts bool patch as bridge
> > >>>>> to the new call_usermodehelper()  since its the cleanest=20
> > >>>>> solution so far...=20
> > >>>>>=20
> > >>>>> Thoughts?
> > >>>>=20
> > >>>> We have workarounds already that work on every kernel since 3.8.
> > >>>>=20
> > >>> The one that logs 5 to 20 lines (depending on thins are setup or no=
t)
> > >>> per mount? That does work in some environments but no all. ;-)
> > >>=20
> > >> When does running rpc.gssd not work?
> > >=20
> > > Oohh ooh.. Pick me.  Pick me!! I can answer that one.
> > >=20
> > > Running rpc.gssd does not work if you are mounting a filesystem using=
 the IP
> > > address of the server and that IP address doesn't have a matching hos=
tname
> > > anywhere that can be found:
> > >=20
> > > In a newly creating minimal kvm install without rpc.gssd running,
> > >   mount 10.0.2.2:/home /mnt
> > >=20
> > > sleeps for 15 seconds then succeeds.
> > > If I start rpc.gssd, then the same command takes forever.
> > >=20
> > > strace of rpc.gssd shows that it complains about not being able to re=
solve
> > > the host name and "ERROR: failed to read service info".  Then it keep=
s the
> > > pipes open but never sends any message on them, so the kernel just ke=
eps on
> > > waiting.
> > >=20
> > > If I change "fail_keep_client" to "fail_destroy_client", then it clos=
es the
> > > pipe and we get the 15 second timeout back.
> > > If I change  NI_NAMEREQD to 0, then the mount completes instantly.  (=
of course
> > > that make serious compromise security so it was just for testing).
> > > (Adding an entry to /etc/hosts also gives instant success).
> > >=20
> > > I'm hoping that someone who understands this code will suggest someth=
ing
> > > clever so I don't have to dig through all of it ;-)
> >=20
> > rpc.gssd is supposed to do a downcall with a zero-length window and an =
error message in any situation where it cannot establish a GSS context. Nor=
mally, I=E2=80=99d expect an EACCES for the above scenario.
> >=20
> > IOW: that=E2=80=99s a blatant rpc.gssd bug. One that will also affect y=
ou when you're doing NFSv3 and add =E2=80=98sec=3Dkrb5=E2=80=99 to the moun=
t options.
>=20
> Also why is gssd trying to do a DNS lookup in this case?  This sounds
> similar to what f9f5450f8f94 "Avoid DNS reverse resolution for server
> names (take 3)" was trying to fix?

It is quite possible that I misunderstand something.  But this is my
understanding.

1/ "mount" allows you to use either an IP address or a host name to mount a
   filesystem.
2/ gss requires a hostname to identify the server and find it's key (IP not
   sufficient).
3/ If you use a host name to mount a filesystem, then that exact same host
   name should be used by gssd to identify the server and its key.
   The above mentioned patch was trying to enforce this.  The idea was to
   collect the name given to the 'mount', see if it looked like an IP addre=
ss
   or a Server name.  If the later, just use it.  If the former, do a rever=
se
   lookup because an IP address is no use by itself for gss.
   Previously it would always do a reverse DNS lookup from the IP address
   that was determined from the server-name-or-IP-address.
   Unfortunately this patch was broken - got the test backwards.
   A follow-up patch fixed the test: c93e8d8eeafec3e32

4/ So the above patch was not intended to address the case of mount-by-IP
   address at all - and this is the case that is causing me problems.


But back to my problem:  Following Trond's suggestion I've come up with the
following patch.  Does it look right?

The "fd =3D -1" is just to stop us trying to close a non-open fd in an error
path.

The change from testing ->servicename to ->prog stops us from repeating the
failed DNS lookup on every request, not that the failure isn't fatal.

The last stanza makes sure we always reply to an upcall, with EINVAL if
nothing else seems appropriate.

The patch seems to work for my particular case but a more general review
would be appreciated.

Thanks,
NeilBrown



diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index b48d1637cd36..00b4bc779b7c 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -256,6 +256,7 @@ read_service_info(char *info_file_name, char **servicen=
ame, char **servername,
 	if ((nbytes =3D read(fd, buf, INFOBUFLEN)) =3D=3D -1)
 		goto fail;
 	close(fd);
+	fd =3D -1;
 	buf[nbytes] =3D '\0';
=20
 	numfields =3D sscanf(buf,"RPC server: %127s\n"
@@ -403,11 +404,10 @@ process_clnt_dir_files(struct clnt_info * clp)
 		return -1;
 	snprintf(info_file_name, sizeof(info_file_name), "%s/info",
 			clp->dirname);
-	if ((clp->servicename =3D=3D NULL) &&
-	     read_service_info(info_file_name, &clp->servicename,
-				&clp->servername, &clp->prog, &clp->vers,
-				&clp->protocol, (struct sockaddr *) &clp->addr))
-		return -1;
+	if (clp->prog =3D=3D 0)
+		read_service_info(info_file_name, &clp->servicename,
+				  &clp->servername, &clp->prog, &clp->vers,
+				  &clp->protocol, (struct sockaddr *) &clp->addr);
 	return 0;
 }
=20
@@ -1320,11 +1320,14 @@ handle_gssd_upcall(struct clnt_info *clp)
 		}
 	}
=20
-	if (strcmp(mech, "krb5") =3D=3D 0)
+	if (strcmp(mech, "krb5") =3D=3D 0 && clp->servername)
 		process_krb5_upcall(clp, uid, clp->gssd_fd, target, service);
-	else
-		printerr(0, "WARNING: handle_gssd_upcall: "
-			    "received unknown gss mech '%s'\n", mech);
+	else {
+		if (clp->servername)
+			printerr(0, "WARNING: handle_gssd_upcall: "
+				 "received unknown gss mech '%s'\n", mech);
+		do_error_downcall(clp->gssd_fd, uid, -EINVAL);
+	}
=20
 out:
 	free(lbuf);

--Sig_/xlPCVnJmyEZv9ETL/avnday
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUoLGkznsnt1WYoG5AQJcFBAAgWazArWI6RfzX3AR77jz9N76Sybff24v
Ug6/YC3MtEGgZnfHbGh6xQImIouDQZlh/sFr4r46URzT4OWapI6lKGH3Fq8cz/Bs
CtWF8XnrfPfvhxzibnNZehE3nzKY9Ta7qSvc1sCtoS/85wV6lgBMjPzQGmrTJKJ5
Wj3p0RuS9IJHcMY3lVvByZCMaM+1G3n6koUN1Dk3NnZYtv1x+u/Mv5rRnk/3/4dx
zBA3D/DGcH2O9ZM4JXW/9Cr9S97Bo3GCVvKw9ISOBeCVxVhRJBsHsRVdG0uh0leI
SBNo9b8YGOUXuzFBC0hPhLPrDKoEa00ikE3nhAaFVNttYB2smKaN0jweepMgzW96
Bxe92Un8CAcL3mioWDGcLSU3ADMN/wtR/545mzPdAeG/+YR21JnE5SdCVK3qhjga
4Eqo+fPv6WB2Q2ORVxiOX32emp8RnbOOch1CUjfjiENcDvKtG0Ck8hY3e+iH1oWr
0LItY3pxlJ6lbsZhIJUOUqRK1grMxxV/BLsjbCwGT93SunTu+ML0Q0KLhSBr8HXt
tI1ftMrJG/R45j+HC1Az2jdEo/iEFtFQKRTPmJy3PCLJyLKCK3oNzOZV6xhPNV+g
+RST4YSVrbJTRbl9xKIPzaYv6pcNJT+6+9C66/6JXTcJbWlO0+IMjb5fhU7MxFyx
refuCJGSAkI=
=ecxA
-----END PGP SIGNATURE-----

--Sig_/xlPCVnJmyEZv9ETL/avnday--

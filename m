From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFS readonly failover and linux?
Date: Thu, 17 Feb 2005 13:59:27 -0800
Message-ID: <1108677567.5897.55.camel@seki.nac.uci.edu>
References: <1106871309.6181.254.camel@seki.nac.uci.edu>
	 <Pine.LNX.4.61.0501291127450.1607@donald.themaw.net>
	 <1107205302.4071.17.camel@seki.nac.uci.edu>
	 <Pine.LNX.4.58.0502010945400.25875@wombat.indigo.net.au>
	 <16895.57760.531261.8465@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-xor42ircdY8NYJMozeRK"
Cc: strombrg@dcs.nac.uci.edu, Ian Kent <raven@themaw.net>,
	autofs mailing list <autofs@linux.kernel.org>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1tgN-0005Du-2z
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 13:59:35 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D1tgM-0004mQ-Gb
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 13:59:34 -0800
To: jmoyer@redhat.com
In-Reply-To: <16895.57760.531261.8465@segfault.boston.redhat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-xor42ircdY8NYJMozeRK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2005-02-01 at 15:08 -0500, Jeff Moyer wrote:
> =3D=3D> Regarding Re: [NFS] NFS readonly failover and linux?; Ian Kent <r=
aven@themaw.net> adds:
>=20
> raven> On Mon, 31 Jan 2005, Dan Stromberg wrote:
> >> On Sat, 2005-01-29 at 11:46 +0800, raven@themaw.net wrote: > On Thu, 2=
7
> >> Jan 2005, Dan Stromberg wrote:
> >> >=20
> >> > >
> >> > > The autofs man pages on Redhat Enterprise Linux 3 as well as Fedor=
a
> >> Core > > 3 both say that autofs supports replicated, readonly fileserv=
er
> >> failover > > - but then there's a footnote of sorts that says autofs
> >> only supports it > > to the extent that mount does.
> >> >=20
> >> > That part of the man page is old and slightly out of date.
> >> >=20
> >> > The reason that this is left there is that autofs cannot support >
> >> dynamic failover as it just uses mount. However, a different host may =
be
> >> > selected at mount, after a previous timeout, for example. The issue =
of
> >> > umounting existing mounts from servers that have gone away is not >
> >> explicitly dealt with yet.
> >>=20
> >> I see.
> >>=20
> >> > >
> >> > > Upon trying to do such a mount, I get:
> >> > >
> >> > > seki-root> mount > >
> >> dcslib1.nacs.uci.edu,dcslib4.nacs.uci.edu:/dcspdb/rhel-3-i686 /mnt/nfs=
 >
> >> > mount: warning: multiple hostnames not supported > > Thu Jan 27
> >> 16:12:18
> >>=20
> >> > What version of autofs are you using?  > The autofs replicated serve=
r
> >> code is still relatively new.
>=20
> raven> But, as we know, mount doesn't know about multiple host
> raven> names. autofs breaks these out.
>=20
> So what is the actual problem, here?  Are you using the automounter?  Wha=
t
> do your config files look like?
>=20
> >> FC3: autofs-4.1.3-28 RHEL3: autofs-4.1.3-47
>=20
> raven> I believe that the replicated server code should be present in bot=
h
> raven> of these.
>=20
> raven> Can you confirm please Jeff?
>=20
> raven> Perhaps you are seeing a bug which needs to be addressed.
>=20
> Yes, the replicated server code is present in both of these versions.
>=20
> >> The FC3 is yum update'd fairly regulary, and the RHEL3 is up2date'd
> >> regularly as well.
> >>=20
> >> > If your autofs supports replicated server map entries then multiple =
>
> >> host mount requests will not reach the mount command.
> >>=20
> >> Interesting.
> >>=20
> >> > If you are using a RedHat based distro then check >
> >> http://people.redhat.com/jmoyer > for the latest patched versions
> >> >=20
> >> > Also, you may need a kernel patch depending on your kernel
> >> version. See > README.patches in the distribution or join the autofs
> >> list at > http://linux.kernel.org/mailman/listinfo/autofs
> >>=20
> >> I'm certain my management will only go for this, in the short term, if
> >> it works on a mainstream RHEL3 system.  Unfortunately, for me, the res=
t
> >> is academic interest.
>=20
> raven> Once again I believe that the kernels mentioned here are up to dat=
e
> raven> wrt autofs.
>=20
> raven> Certainly, the latest FC3 kernel is at 2.6.10 which has all the
> raven> autofs4 updates included in the base kernel.
>=20
> raven> I believe the latest update to RHEL3 is also up to date. Jeff?
>=20
> Yes, both kernels have the necessary patches to support replicated server=
.
>=20
> raven> So perhaps you could send a log trace with the "--debug" option
> raven> added to the master map entry.
>=20
> And please include the contents of your maps!
>=20
> -Jeff

Here are the maps we use on Solaris 9.  Should they work the same way on
RHEL 3?

autoinst-strombrg> cat /etc/auto_dcslib
/dcs -ro
dcslib1.nacs.uci.edu,dcslib2.nacs.uci.edu,dcslib3.nacs.uci.edu:/dcspdb/sun4=
-5
/dcslib -ro
dcslib1.nacs.uci.edu,dcslib2.nacs.uci.edu,dcslib3.nacs.uci.edu:/dcspda

autoinst-strombrg> cat /etc/auto_master
# Master map for automounter
#
+auto.master
/net            -hosts          -nosuid,nobrowse
#/home          auto_home       -nobrowse
/xfn            -xfn
/-             auto_direct



--=-xor42ircdY8NYJMozeRK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCFRO/o0feVm00f/8RAg9sAJ9iL6pMdqtA7P5+nl+Hw9vWouCpfQCfZ7wz
wc8ilKpxD/eFcSgT0iJtwAI=
=ioQ7
-----END PGP SIGNATURE-----

--=-xor42ircdY8NYJMozeRK--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

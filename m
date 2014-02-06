Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34347 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367AbaBFB2D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Feb 2014 20:28:03 -0500
Date: Thu, 6 Feb 2014 12:27:51 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140206122751.41b2fbf9@notabene.brown>
In-Reply-To: <1B2F95A4-8439-4274-A859-F33986D06824@oracle.com>
References: <20140130172451.7a354ce4@notabene.brown>
	<52F003A1.3060908@RedHat.com>
	<20140204093452.7b6d7c7d@notabene.brown>
	<20140204162052.GA5295@fieldses.org>
	<20140205140906.0b3ba9fd@notabene.brown>
	<1B2F95A4-8439-4274-A859-F33986D06824@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/tPvgtMW/IXjtKHYzOwu0EjB"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/tPvgtMW/IXjtKHYzOwu0EjB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Feb 2014 10:56:39 -0500 Chuck Lever <chuck.lever@oracle.com> wrot=
e:

> Hi Neil!
>=20
>=20
> On Feb 4, 2014, at 10:09 PM, NeilBrown <neilb@suse.de> wrote:
>=20
> > On Tue, 4 Feb 2014 11:20:52 -0500 "J. Bruce Fields" <bfields@fieldses.o=
rg>
> > wrote:
> >=20
> >> On Tue, Feb 04, 2014 at 09:34:52AM +1100, NeilBrown wrote:
> >>> Also, I've been wondering if we could avoid the need to explicitly en=
able
> >>> the gss stuff by gating it on the existence of /etc/krb5.keytab.
> >>> Do you think that would be reasonable?
> >>=20
> >> That would be great.  I hate that people have to care about these
> >> support daemons, they should just be started automatically when they're
> >> needed.
> >>=20
> >> Is /etc/krb5.keytab the best indicator?
> >=20
> > I was hoping you would tell me. :-)
>=20
> rpc.gssd has to run in cases where there is no /etc/krb5.keytab.  Remembe=
r the discussion we had last year about using root=E2=80=99s user credentia=
l as the client=E2=80=99s machine credential?  We want the kernel to be abl=
e to find out whether there is a machine credential available, and one can =
be available even if there is no keytab.

Hi Chuck,
 thanks for reminding me about that!  Yes we clearly cannot key
 off /etc/krb5.keytab for rpc.gssd.

 Maybe /etc/krb5.conf?  Seems a bit lame.
 How about  /etc/gssapi_mech.conf ??  rpc.gssd seems to exit if that doesn't
 exist.  What if systemd is told not to run rpc.gssd if that file is
 missing?

 I guess that otherwise we can make it on-by-default, but document that peo=
ple
 can turn it off with
     systemctl mask rpc-gssd

 which is probably easier that requiring "systemctl enable nfs-secure".

>=20
> > It occurred to me as a good test when I tried running rpc.svcgssd in a =
fresh
> > VM and it wouldn't start.  I eventually found the error message complai=
ning
> > that it couldn't find that file.
> >=20
> > It isn't perfect as an empty /etc/krb5.keytab will still result in fail=
ure
> > and exit.  However if a sysadmin has created a keytab and is using NFS,=
 it
> > seems reasonable to be ready to provide gss services.
> >=20
> > rpc.gssd doesn't fail in the same way, but it does complain if the file
> > doesn't exist, so I suspect it is at least a good indicator.
> >=20
> > The only thing that bothers me is that gssd is theoretically more gener=
al
> > than krb5.  However as the reality seems to be that it is exactly krb5,=
 I
> > don't let that bother me too much.
> >=20
> >>=20
> >> Simplest might be to start unconditionally and just not care if it
> >> fails.  Or is there a problem cluttering up logs with unimportant
> >> failures?
> >=20
> > More a problem with starting things that aren't necessary, and possibly
> > leaving them running.
> > Every process you start adds a little to the boot time.  We only get th=
e best
> > experience if everyone contributes a little bit, no matter how little.
> > Also, every running process theoretically adds the to the attack servic=
e.
>=20
> rpc.gssd doesn=E2=80=99t expose a network listener.  What attack vector i=
s exposed by running rpc.gssd?

Not all attacks are external.  Also not all decisions relating to security
are completely rational.  And the 'attack surface' argument may apply better
to other services but might cause a spill-over to people not wanting to run
anything they don't have to.

>=20
> Why would we insist on using a potentially insecure mechanism to provide =
strong security?
>=20
> > So some people will definitely not want these processes to be started.
>=20
> How many such people are there?  The trend I expect is that more and more=
 people will want to use security features, and fewer will want =E2=80=9Cse=
c=3Dsys,=E2=80=9D especially if we work hard to make security features as p=
ainless as possible (as we should be doing).

I honestly don't know.  I may be seeing spectres that aren't there.  But I'=
ve
certainly heard a strong preference to not run unnecessary daemons more than
once in the past.

When NFS is only used over a tightly coupled local network (infiniband?) you
really do want sec=3Dsys.


>=20
> It seems to me that provisionally starting rpc.gssd optimizes for a fairl=
y uncommon case that will become less and less common going forward.  I bel=
ieve we should start designing as if security is the default use case.  I w=
ould feel more comfortable if we knew more precisely what proportion of our=
 users want to disable gssd and why.
>=20
> > i.e. I agree with SteveD:=20
> >> I think we want to stay away (and move away) from unconditionally
> >> starting anything=E2=80=A6=20
>=20
> I believe we should make things simple both for us and for our customers.=
  Thus I agree philosophically with the Gnome strategy of removing less fre=
quently used configuration options to reduce complexity, make things easier=
 to configure, more reliable, and easier to troubleshoot.

I certainly agree with making things simple.  If we can make a configuration
irrelevant, e.g. by gets nfsd to auto-tune the number of threads so the
setting becomes pointless, then I've very happy to remove that sort of
configuration.  But if a configuration option actually means something I
certainly don't want to remove it.

So I'm leaning towards having "systemctl {un,}mask rpc-gssd" be the
configuration tool for rpc.gssd.

Thanks,
NeilBrown

--Sig_/tPvgtMW/IXjtKHYzOwu0EjB
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvLlFznsnt1WYoG5AQIZug//UX5T/5gy72y8dkBwRRra69vcF1JAU+k1
4CwheSVafQRnuKvWYAHP2qzgdMTUPY8lWwJLfvqiGPtYeJEjPsAl65jXi86S9Frl
gf46P4vsTbhja8R0aHRMaCOtna/xuEMoPAp4qr6l68AMPwzyHtRdalZpxL/Ul+Po
MzvHANMJckzfpFSjb8UzHnmxFjQDqpvewZ51XFcyCMCUDBSansg/cOH+KQpBQ/Zp
vq5pe7RBANv3OwrRSPHwvE8pCVVgjW3HVUJw4+2ejTDWK7f9zH0508W3Igw+agGf
wZoPvper5RjUfsXYeiC+ORlUBeZ+yLV2YIwTVMygyPAILpg+aQMtr8kQiIO1UxJS
bxqvf4JFjuZKPww+JHk9OjpTEpU7eyH7/sdwYCSrtCKZUGFDNznwd3nGZ11+HYeX
ZkxH+P4cBg3wF/AtuUDewhSGDsGG4pgMLrSTLPKf1T4QGr85VbrUXr4hU8xORR9V
nb0P0ogPXzipqxZxbMzI7vUaQ62DVNdFpXRQBHgZVSmG8d6uIBRctqitCkZvv+Rx
iRHN/ZlH1EGsEUQE9Eg9xj0GCMnFBpVtLHUFxUr8diBmJI9ufGjeMQtvKKzj5rny
nrVWCLmXmPdygmXGRe1S/jbvWGRbCoT98kKFwF3AyefTmx2SteA9C03FQ3VNvXtB
Et7loJ5W2EY=
=Vy8g
-----END PGP SIGNATURE-----

--Sig_/tPvgtMW/IXjtKHYzOwu0EjB--

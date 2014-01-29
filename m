Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43083 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750805AbaA2HKV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jan 2014 02:10:21 -0500
Date: Wed, 29 Jan 2014 18:10:08 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>,
        Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir vs. getattr
Message-ID: <20140129181008.10d7ac3a@notabene.brown>
In-Reply-To: <1365090480.10726.22.camel@leira.trondhjem.org>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	<20130404151507.GA8484@umich.edu>
	<CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com>
	<1365090480.10726.22.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/FDiTsB/OUFZ0uhQfjC.5cK2"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/FDiTsB/OUFZ0uhQfjC.5cK2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 4 Apr 2013 15:48:01 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-04-04 at 17:38 +0200, Tigran Mkrtchyan wrote:
> > On Thu, Apr 4, 2013 at 5:15 PM, Jim Rees <rees@umich.edu> wrote:
> > > Tigran Mkrtchyan wrote:
> > >
> > >   we have a directory with 50K (number of )  files in it.
> > >   The user does a 'ls' and I can see READDIR4. To
> > >   get the complete listing a client need to send ~380 requests.
> > >   Now user does yet another 'ls' in the same directory.
> > >   The client sends a GETATTR  on directorie's FH
> > >   (actually two of GETATTRS - why?!!) and discovers that a
> > >   directory didn't change and re-uses existing listing, BUT!!!
> > >   for each file in the directory it sends a GETATTR to discover
> > >   is  the file's attributes are changed. For 50K files it's a 50K req=
uests.
> > >
> > > So is this a "ls -l"? Because for "ls" it shouldn't stat all the file=
s.
> >=20
> > I believe it's 'ls -l'.  Well, you probably want to say that it's ls
> > calling stat on each file. Nevertheless client still should re-use
> > cached information.
>=20
> What makes you think that it isn't using cached information? I'm
> guessing you just need to adjust the values of acregmin and acregmax
> upwards.
>=20
> That said, we might be able to be a little more intelligent about how we
> use the NFS_INO_ADVISE_RDPLUS hint, and have it blow out the readdir
> cache when we find ourselves doing lots of lookup revalidates.
>=20

Pop.

I recently had a customer raise exactly this issue with me, so I've been
looking into it.

I don't think it can really be fixed by adjusting acregmin/acregmax.

Once you have done READDIRPLUS, you have the directory contents in the
page-cache and will continue to use those contents until they drop out of t=
he
cache, or until the directory changes in some way.

Meanwhile the stat information from the READDIRPLUS was used to create/upda=
te
info in the inode table and that will eventually become stale.  As soon as =
it
becomes stale you get a GETATTR storm on the next "ls -l" instead of a few
READDIRPLUS calls.  By increasing acregmin you can delay that storm, but you
can put it off forever.

Fixing this is tricky.  We really want to know on the first nfs_readdir() c=
all
whether it will be followed by lookups or not.  If it won't, then using the
cached data is fine.  If it will, then we really want a READDIRPLUS.

The only way I can see to address this is for nfs_advise_use_readdirplus  (=
or
code near where that is called) to notice that a readdir is currently active
on the same directory and is using cached data, and to re-use that 'open' of
the directory to do a readdirplus.  This would update the stat info for the
current inode and all the other inodes for the directory.

This is fairly horrible.  The 'struct file' used by the readdir would need =
to
be stored somewhere so that nfs_lookup_revalidate can use it (if process
permissions allow).  If multiple processes were doing a readdir at the same
time .... I would certainly get confused.

However I cannot think of anything else that would even come close to being=
 a
real solution.

Any solution that just modified nfs_readdir() could only avoid the GETATTR
storm by largely ignoring the cached information and (almost) always calling
READDIRPLUS.

Does anyone have any other ideas?  Or do you think it is worth trying to
implement the above "horrible" idea.  I did start working on it, but only g=
ot
far enough to understand the full extend of what is required.

Thanks,
NeilBrown

--Sig_/FDiTsB/OUFZ0uhQfjC.5cK2
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUuipUDnsnt1WYoG5AQJTIA/7B1T1EPb5O4HQvaeyWfnfZe+BgC4cjuVj
/Xq1Rf+v2d0PdKtyXh49jnhfzsZBO/5Ctvrwf23OAKeKFh348qCavtrExqCfi0g0
+X3Sj4rsdSDueymRioyddFc/mC15BuXzpK9KSHkvZPs/D3UtZejacXOeZadr9dt9
nvIT3HmcOvmO9RgttK/ksDlmnEp4QBQlZ90WsgbdwPXgV3KbI5JB7yWM43YIi1VA
RPqUdgA1P+gvsTZ0UUi+8yQO9bxigkb5x2UklXSkImiMdvZZvYStGCE0FPnaaW4b
Hpd0FUImI0aCcVO8k3MzMLPGLopZ/3oS/imwnrNKk33AnaXL6s3Ep5syTIEPEyUc
aM5trC50AL/ffuhzWq8Ak/zfYGPoTHubnq1U+UxwGJ54Rgolc/icYWMdVOeJ7zFu
biK/McAFrISnhSMtloDlHc0vJx6/2rZj2rnTmPHkcrXyVQTOW4j2rtLU2F62EYTb
p8hB7JzoNbi+A31L1LN/TdKXwUQ70CauTa5FH4Trdu3Fro694bypXxtS1jE8G4JT
u/GC6kcOJNvgM2RkuFVvQW9mhCxG/G3iehnC+7Gp2UxUpIXjq/mMhze6x2Wd/1o7
SiSPnLmVlLjeSp+PzdaUpUciA5b1mmm/7g03Jx4v0wRK02jMSxj50BsO13rYNg1f
Dh4mcVdQO8k=
=z6F8
-----END PGP SIGNATURE-----

--Sig_/FDiTsB/OUFZ0uhQfjC.5cK2--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:36581 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753488Ab3G3CtM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Jul 2013 22:49:12 -0400
Date: Tue, 30 Jul 2013 12:48:57 +1000
From: NeilBrown <neilb@suse.de>
To: "J.Bruce Fields" <bfields@citi.umich.edu>
Cc: Ben Myers <bpm@sgi.com>, Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD/sunrpc: avoid deadlock on TCP connection due to
 memory pressure.
Message-ID: <20130730124857.7c066858@notabene.brown>
In-Reply-To: <20130726141916.GA30651@fieldses.org>
References: <20130710190727.GA22305@fieldses.org>
	<20130715143203.51bc583b@notabene.brown>
	<20130716015803.GA5271@fieldses.org>
	<20130716140021.312b5b07@notabene.brown>
	<20130716142430.GA11977@fieldses.org>
	<20130718000319.GL1681@sgi.com>
	<20130724210746.GB5777@fieldses.org>
	<20130725113023.7bcbc347@notabene.brown>
	<20130725201805.GB17962@fieldses.org>
	<20130726063303.0d1495b3@notabene.brown>
	<20130726141916.GA30651@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/GxYcf1Gn0mkfMppDq0B0QXP"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/GxYcf1Gn0mkfMppDq0B0QXP
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 26 Jul 2013 10:19:16 -0400 "J.Bruce Fields" <bfields@citi.umich.edu>
wrote:

> On Fri, Jul 26, 2013 at 06:33:03AM +1000, NeilBrown wrote:
> > On Thu, 25 Jul 2013 16:18:05 -0400 "J.Bruce Fields" <bfields@citi.umich=
.edu>
> > wrote:
> >=20
> > > On Thu, Jul 25, 2013 at 11:30:23AM +1000, NeilBrown wrote:
> > > >=20
> > > > Since we enabled auto-tuning for sunrpc TCP connections we do not
> > > > guarantee that there is enough write-space on each connection to
> > > > queue a reply.
> ...
> > > This is great, thanks!
> > >=20
> > > Inclined to queue it up for 3.11 and stable....
> >=20
> > I'd agree for 3.11.
> > It feels a bit border-line for stable.  "dead-lock" and "has been seen =
in the
> > wild" are technically enough justification...
> > I'd probably mark it as "pleas don't apply to -stable until 3.11 is rel=
eased"
> > or something like that, just for a bit of breathing space.
> > Your call though.
>=20
>=20
> So my takeaway from http://lwn.net/Articles/559113/ was that Linus and
> Greg were requesting that:
>=20
> 	- criteria for -stable and late -rc's should really be about the
> 	  same, and
> 	- people should follow Documentation/stable-kernel-rules.txt.
>=20
> So as an exercise to remind me what those rules are:
>=20
> Easy questions:
>=20
> 	- "no bigger than 100 lines, with context."  Check.
> 	- "It must fix only one thing."  Check.
> 	- "real bug that bothers people".  Check.
> 	- "tested": yep.  It doesn't actually say "tested on stable
> 	  trees", and I recall this did land you with a tricky bug one
> 	  time when a prerequisite was omitted from the backport.
>=20
> Judgement calls:
>=20
> 	- "obviously correct": it's short, but admittedly subtle, and
> 	  performance regressions can take a while to get sorted out.
> 	- "It must fix a problem that causes a build error (but not for
> 	  things marked CONFIG_BROKEN), an oops, a hang, data
> 	  corruption, a real security issue, or some "oh, that's not
> 	  good" issue.  In short, something critical."  We could argue
> 	  that "server stops responding" is critical, though not to the
> 	  same degree as a panic.
> 	- OR: alternatively: "Serious issues as reported by a user of a
> 	  distribution kernel may also be considered if they fix a
> 	  notable performance or interactivity issue." The only bz I've
> 	  personally seen was the result of artificial testing of some
> 	  kind, and it sounds like your case involved a disk failure?
>=20
> --b.

Looks like  good analysis ... except that it doesn't seem conclusive.  Being
conclusive would make it really good. :-)

The case that brought it to my attention doesn't require the fix.
A file system was mis-behaving (blocking when it should return EJUKEBOX) and
this resulted in nfsd behaviour different than my expectation.
I expected nfsd to keep accepting requests until all threads were blocks.
However only 4 requests were accepted (which is actually better behaviour,
but not what I expected).
So I looked into it and thought that what I found wasn't really right.  Whi=
ch
turned out to be the case, but not the way I thought...

So my direct experience doesn't argue for the patch going to -stable at all.
If the only other reports are from artificial testing then I'd leave it out
of -stable.  I don't feel -rc4 (that's next I think) is too late for it
though.

NeilBrown


--Sig_/GxYcf1Gn0mkfMppDq0B0QXP
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUfcpmTnsnt1WYoG5AQITnQ/9G0wbE/hJBnU8KNtkEsbkNl2KmtrLh82y
wxh0jbIOvYBqVr1Ttzm/Cb7tKRfqB/f4c+HYtVj7a9uaNu/R5+QlPzJWN+SE3gal
2xf8nT8Ddkio0CiZ8Yj5/8pYQqqkvGa9qGFOCdAfmLHabfimXi/dM08JmfAYSxRJ
13s+uaf4RRYXsMMWjDD3xXD7LLhtkD3aXv0zSnrZjQXEiBZ+d8bIdKJOGeqwG8EL
SXtPjS1kWkTdXcQtB6q90INo7p1UaEsb8PWs74N5Jx+1vGcbpHKXBM1mLZwmkVKH
2RsGK6A/uRJX9IBZSoirSXJwpTCzv7Qi9uLi/IDTcweoZWmOKhznOrXuAhsCHveT
pg05Aw6xklJCVAyqxBnYT5NIrSC/x11uU6YSEx5X2GPeuzl4WvZyqfQ7zQlsOBGV
ZGsDQ5rKZ6LRkAN0/YOr/ONhla5j+6f3rPf5sgr5L/pm1WRXNK/QVcaspCjpyASb
kSBK0VL139dEErWQ3XBz5o6xZtLVsXAQ+esodGXkUJHNRNmhFRh0Y3stww61UtEq
sDoGI/YB7iBdP5wg9YqF0kB9NPfovsYc/sB6cx2dcWBeXtl1kGr5/b2tc5Kx666l
tHIDSfjHtQxWhSrFZQ/rabGVZDdQfroOjv3SiUpRV5XbX38fUge5IXXlMUxUjVbn
yEHQBEHruRU=
=D9D9
-----END PGP SIGNATURE-----

--Sig_/GxYcf1Gn0mkfMppDq0B0QXP--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46801 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790AbaCFFh3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2014 00:37:29 -0500
Date: Thu, 6 Mar 2014 16:37:21 +1100
From: NeilBrown <neilb@suse.de>
To: Andrew Martin <amartin@xes-inc.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
Message-ID: <20140306163721.0edfb498@notabene.brown>
In-Reply-To: <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>
	<260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com>
	<20140306145042.6db53f60@notabene.brown>
	<1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/UWItXpWL86g4q4yI=V2JBvQ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/UWItXpWL86g4q4yI=V2JBvQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Mar 2014 23:03:43 -0600 (CST) Andrew Martin <amartin@xes-inc.com>
wrote:

> ----- Original Message -----
> > From: "NeilBrown" <neilb@suse.de>
> > To: "Andrew Martin" <amartin@xes-inc.com>
> > Cc: linux-nfs@vger.kernel.org
> > Sent: Wednesday, March 5, 2014 9:50:42 PM
> > Subject: Re: Optimal NFS mount options to safely allow interrupts and t=
imeouts on newer kernels
> >=20
> > On Wed, 5 Mar 2014 11:45:24 -0600 (CST) Andrew Martin <amartin@xes-inc.=
com>
> > wrote:
> >=20
> > > Hello,
> > >=20
> > > Is it safe to use the "soft" mount option with proto=3Dtcp on newer k=
ernels
> > > (e.g
> > > 3.2 and newer)? Currently using the "defaults" nfs mount options on U=
buntu
> > > 12.04 results in processes blocking forever in uninterruptable sleep =
if
> > > they
> > > attempt to access a mountpoint while the NFS server is offline. I wou=
ld
> > > prefer
> > > that NFS simply return an error to the clients after retrying a few t=
imes,
> > > however I also cannot have data loss. From the man page, I think these
> > > options
> > > will give that effect?
> > > soft,proto=3Dtcp,timeo=3D10,retrans=3D3
> > >=20
> > > >From my understanding, this will cause NFS to retry the connection 3=
 times
> > > >(once
> > > per second), and then if all 3 are unsuccessful return an error to the
> > > application. Is this correct? Is there a risk of data loss or corrupt=
ion by
> > > using "soft" in this way? Or is there a better way to approach this?
> >=20
> > I think your best bet is to use an auto-mounter so that the filesystem =
gets
> > unmounted if the server isn't available.
> Would this still succeed in unmounting the filesystem if there are already
> processes requesting files from it (and blocking in uninterruptable sleep=
)?

The kernel would allow a 'lazy' unmount in this case.  I don't know if any
automounter would try a lazy unmount though - I suspect not.

A long time ago I used "amd" which would create syslinks to a separate tree
where the filesystems were mounted.  I'm pretty sure that when a server went
away the symlink would disappear even if the unmount failed.
So while any processes accessing the filesystem would block, new processes
would not be able to find the filesystem and so would not block.


>=20
> > "soft" always implies the risk of data loss.  "Nulls Frequently Substit=
uted"
> > as it was described to very many years ago.
> >=20
> > Possibly it would be good to have something between 'hard' and 'soft' f=
or
> > cases like yours (you aren't the first to ask).
> >=20
> >  From http://docstore.mik.ua/orelly/networking/puis/ch20_01.htm
> >=20
> >    BSDI and OSF /1 also have a spongy option that is similar to hard , =
except
> >    that the stat, lookup, fsstat, readlink, and readdir operations beha=
ve
> >    like a soft MOUNT .
> >=20
> > Linux doesn't have 'spongy'.  Maybe it could.  Or maybe it was a failed
> > experiment and there are good reasons not to want it.
>=20
> The problem that sparked this question is a webserver where apache can se=
rve
> files from an NFS mount. If the NFS server becomes unavailable, then the =
apache
> processes block in uninterruptable sleep and drive the load very high, fo=
rcing
> a server restart. It would be better for this case if the mount would sim=
ply=20
> return an error to apache, so that it would give up rather than blocking=
=20
> forever and taking down the system. Can such behavior be achieved safely?

If you have a monitoring program that notices this high load you can try
  umount -f /mount/point

The "-f" should cause outstanding requests to fail.  That doesn't stop more
requests being made though so it might not be completely successful.
Possibly running it several times would help.

  mount --move /mount/point /somewhere/safe
  for i in {1..15}; do umount -f /somewhere/safe; done

might be even better, if you can get "mount --move" to work.  It doesn't wo=
rk
for me, probably the fault of systemd (isn't everything :-)).

NeilBrown



--Sig_/UWItXpWL86g4q4yI=V2JBvQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxgJkTnsnt1WYoG5AQInMw/+IsLKXwwiFC3PLnxluK1aai9CiKK0dAQr
YbRZra1PNmDcL7MEPjWXPfT9zGRwHUIuxO/Qi9ELjMjeZ4fBSJLeAj0P4Smas2cE
mPCgC9cJLibfReSF/ULWFnPDFGy5VbnsBymdi+BwAQhOn/yViqnIct7JpY8xzRM2
lwFLQyXv1FMdScO7QEwqcniVBzyilrkLZxexrqI17cKG4OPAnPnmfQxQBGy7I8rc
dGzKUnyChyD+qo87sgKsXf/t2YWCCXlG3olGGJfGtMRuHfDH5T0SneAM8RM/2Hke
+lDcJiKxj8NoYULrP3NnOIhhTKCQtGdTgQyN/8D5fyeLzHovGQZVmspVyZch3W9O
inOjaTpFTWfqmnpzoBNjTFApJ5/9P2bXuD5/cEe1qID2S7KlEzEG9JqIYAwBr++5
9TwOxAGFYtV+U8H5queqVB9BeqLnZKiMGuMwpfqdpA4duJHBF9eA0WqGAfMnvJIh
xWC1WVtPx02JxIwCeyFQZ2x59+nHrEdH0DW9E/g9voNmIdwP+NM+1IehRf2p5j4q
qZTfinJch3PJdoA7VLfm2aZ/kkj7zgWio3cxYJ7sPnoBV0IxgOczH6ccrO26PRBf
f5ltN7/61qRpyp5V9vHTntTQ96rIuR0LoR7OuZGGWP+HOj/0k2ULZAXyRyBj0Rsy
oTc0J5kf04U=
=nMRm
-----END PGP SIGNATURE-----

--Sig_/UWItXpWL86g4q4yI=V2JBvQ--

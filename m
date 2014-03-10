Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51727 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191AbaCJArZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Mar 2014 20:47:25 -0400
Date: Mon, 10 Mar 2014 11:47:17 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils RPC-PATCH 0/4] Add options to nfsd etc to avoid
 needing to write to /proc
Message-ID: <20140310114717.7df5c24b@notabene.brown>
In-Reply-To: <531B4BB7.9010303@RedHat.com>
References: <20140220063616.6548.42556.stgit@notabene.brown>
	<531B4BB7.9010303@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/UGnkKW6YlZ0ITkI3Ze5LPEn"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/UGnkKW6YlZ0ITkI3Ze5LPEn
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 08 Mar 2014 11:56:23 -0500 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 02/20/2014 01:36 AM, Neil Brown wrote:
> > There are a number of NFS-related setting that currently must be set
> > by writing to various files under /proc.
> > This is a bit clumsy, particularly for systemd unit files.
> >=20
> > So this series adds options to a number of commands where relevant.
> >=20
> > The first two (rdma, and  nfsv4{grace,lease}time) I am quite comfortabl=
e with.
> > The third (nlm grace time) I think is probably right but if someone can=
 argue
> >  an alternate approach I'm unlikely to resist.
> > The fourth is .... uhm.  You better look yourself.
> >=20
> > Part of me thinks that nlm port numbers should be set in /etc/sysctl.co=
nf (or sysctl.d)
> > and /etc/modprobe.d should have something like
> >=20
> >  install lockd  sysctl -p /etc/sysctl.d/lockd
> >=20
> > but last time I tried that it broke "modprobe --show-depends".
> > Also it is awkward to get setting from /etc/sysconfig/nfs into /etc/sys=
ctl.d/lockd
> >=20
> > Thoughts?
> I finally got the cycles to take a look at these... My apologies for
> taking so long...=20

Thanks for getting to it!

>=20
> So I went ahead took a look... Clean them up a bit. There were a couple
> typos and they did not apply cleanly to my tree...  While I was
> doing this I got this gnawing feeling that we probably should have
> some type of global configuration file where all these command
> line variables can be set.=20
>=20
> It would have to be distro friendly meaning the same place in all=20
> distros... Maybe something like /etc/nfsclient.conf patterned off=20
> the /etc/nfsmount.conf config file??=20
>=20
> So I'm thinking it does make sense to have a way to set
> all these but I'm just not keen on how they are being set.
> IDK... Maybe I'm over thinking it.. :-)

I have a couple of (complimentary) thoughts on this.

My early experience with md/raid raid taught me to be very wary of requiring
a config file.  The old "raidtools" requires you to make a config file just
to create an array - or even to stop an array I think.  The new mdadm allows
you do do everything with command line switches and that makes certain thin=
gs
so much easier.

When I was experimenting with fallback from v4 to v3 when TCP is not
supported it was really nice to be able to, e.g.
  rpc.nfsd 0
  rpc.nfsd -T 8
to change nfsd to stop accepting TCP connections.  Had I needed to edit a
config file every time I did that it would have been a pain.

This doesn't mean that config file are bad - not at all.  Just that I really
like that ability to over-ride config files on the command line.

Secondly, we already have a config file for NFS.  It is
call /etc/sysconfig/nfs, though Debian spells it "/etc/default/nfs".

I believe that the best was forward is to make this more standard.
I think the best way to do this is to teach various nfs utilities to use e.=
g.
  getenv("NFS_LISTEN_TCP")
to get defaults for various settings before parsing command line options.
Then whatever is used to run these utilities can
   source /etc/sysconfig/nfs
or
   EnvironmentFile=3D/etc/sysconfig/nfs
first.
Thus we have a ready-made configfile name, a ready-made configfile syntax,
and just need to agree on values can be set.

A particular value of this approach is  that /etc/sysconfig file are easy f=
or
admin tools to manipulate.  SUSE's 'yast' allows markup in the file so that
informative prompts and basic syntax checks can be applied. e.g.:

## Path:                Network/File systems/NFS server
## Description:         number of threads for kernel nfs server
## Type:                integer
## Default:             4
## ServiceRestart:      nfsserver
#
# the kernel nfs-server supports multiple server threads
#
USE_KERNEL_NFSD_NUMBER=3D"8"

We would need to transition from the current setting names to the new agreed
setting names over a couple of released, but that isn't rocket science and =
is
our problem.



>=20
> Finally, during my testing the only flags that seem to work
> was the statd ones:
>=20
> # rpc.nfsd --rdma 8
> rpc.nfsd: Unable to request RDMA services: Protocol not supported

If you don't have configured RDMA hardware on your test machine I would
expect this.  My testing largely involved running the tool under 'strace'
and making sure the correct string was written.

>=20
> # rpc.nfsd --grace-time 66
> rpc.nfsd: Unable to set /proc/fs/nfsd/nfsv4gracetime: Device or resource =
busy
>=20
> # rpc.nfsd --lease-time 66
> rpc.nfsd: Unable to set /proc/fs/nfsd/nfsv4leasetime: Device or resource =
busy
>=20
> Is this expected?

No..  that was a bit careless.
The grace-time and leave-time need to be set before the ports are opened.

i.e. the following incremental patch.  Do you want to merge it with what you
have, or will I resend that patch (or the whole series)?

Thanks,
NeilBrown

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index dbd0d98a8e68..32d22d8ab63b 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -307,11 +307,17 @@ main(int argc, char **argv)
 	}
=20
 	/*
-	 * must set versions before the fd's so that the right versions get
+	 * Must set versions before the fd's so that the right versions get
 	 * registered with rpcbind. Note that on older kernels w/o the right
 	 * interfaces, these are a no-op.
+	 * Timeouts must also be set before ports are created else we get
+	 * EBUSY.
 	 */
 	nfssvc_setvers(versbits, minorvers);
+	if (grace > 0)
+		nfssvc_set_time("grace", grace);
+	if (lease  > 0)
+		nfssvc_set_time("lease", lease);
=20
 	error =3D nfssvc_set_sockets(AF_INET, proto4, haddr, port);
 	if (!error)
@@ -328,10 +334,6 @@ main(int argc, char **argv)
 		if (!error)
 			socket_up =3D 1;
 	}
-	if (grace > 0)
-		nfssvc_set_time("grace", grace);
-	if (lease  > 0)
-		nfssvc_set_time("lease", lease);
=20
 set_threads:
 	/* don't start any threads if unable to hand off any sockets */

--Sig_/UGnkKW6YlZ0ITkI3Ze5LPEn
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUx0LlTnsnt1WYoG5AQLLzxAAt0OfF2I10tpKcFGE2YejSTFmkRqs2i0V
Fk1gJqvRo4Xyn4wOk9yj8A063nSqKt6LdXmCMQ9BUJE6Qj5Dkmj5Rm5La85huFH2
/LQBNCiiA4mLMJhbfW6VQhPS/KOeIo/NoNQy6B1nq2NNgRZUFM8puV8PW0cnCzjh
P05AZ8F5MDSEaXMiww6TYS6KmVO7Q6fQKNLFah7Sm+vEJUMmzPC0j9+CidncAL/o
qgkpu+PfNtoPBccZJU/aHI1FAi01ESn8d7QGXinkznWvKuYuQoqF8v7AuaUzRxFu
tYaVCgx8M8dLeBzN1xYc3aFTJAh4tjiFv5o6dU/MtQGMDL0s9uFTru85JUPJlJ1H
WJrkof0YL2++NpopmXtEOLxDzLbVUXqoSFKEBNjbW2rcoXZqV0X6iCaR5Fnu7XYe
onFFDbmJYKKUXeMD23dW/H6OhGTrSquidmJ8m4yITlT0VEOuDOznzppIE5s9wNVf
7OEuS8NrTU6EKrU9ledIP0S2hzayq5iKPHsUdqb0uqzI1MLnDzlZjuv48MkLgmbX
vD1h53gTLYYGh2WmU2XcqvtlTHDDiVWcq1sa5CGicAE+SxN7AqXfSLpyTVQzbA9y
bzt+61lvBUfnxI/ey5lqQcca7pmoUhh9H6uWLTf1My17L08vwRhy11slhd+oYAIF
apj4NHOHljA=
=87DR
-----END PGP SIGNATURE-----

--Sig_/UGnkKW6YlZ0ITkI3Ze5LPEn--

From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: NFS mount/umount problem
Date: Thu, 16 Jan 2003 16:00:31 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9160C77F9@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ZI3z-0007DT-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Jan 2003 14:00:39 -0800
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


I have similar numbers of nodes and have (under 2.2 series kernels)=20
and if a large number hit the automounter at the same time we
gets lots of failures.   It looks like either the mount program needs
to be adjusted to increase the timeout, or that the automounter
needs to be adjusted to try harder when it gets a failure, the=20
downside to doing either is that it could cause a machine to=20
hang up when a server is down or otherwise unavailable when
with the fast timeout it would just fail (it some cases this is
better, in some it is worse, I would probably say the best would
be to hang forever on the mount - at least until someone kills
it).

It only appears to be a big issue when there are lots of hits happening
in a very short time frame.  =20

I see some the the issues against a sun 2.6 nfs server, but get=20
similar things against linux nfs servers, all from linux clients if
the mob the server at the same time or close to the same time.

			Roger

> Message: 4
> From: "David B. Ritch" <dritch@hpti.com>
> To: NFS mailing list <nfs@lists.sourceforge.net>
> Cc: Craig Tierney <ctierney@hpti.com>
> Organization: High Performance Technologies, Inc.
> Date: 16 Jan 2003 14:17:36 -0500
> Subject: [NFS] NFS mount/umount problem
>=20
> A colleague of mine who is having email difficulties asked me to =
forward
> this to the list.
>=20
> I am having a problem with nfs mounts under linux-2.4.20.
>=20
> Server:
> Redhat-8.0, kernel upgraded to linux-2.4.20 + Trond's NFS Patches.
> Dual PIII 933 Mhz, 2 GB ram, tg3 gigabit ethernet driver.
>=20
> Client
> Redhat-7.1, kernel upgraded to linux-2.4.18 + Trond's NFS patches.
> Dual Xeon 2.2 Ghz, 1 GB ram, e100 ethernet driver.
>=20
> After I upgraded the server from 2.4.14 to 2.4.20, I am having a =
problem
> mounting and unmounting the NFS partitions using autofs. I have all
> of the clients touch the nfs filesystems (ls /misc/scratchx) to cause
> them to mount.  Many of the mounts fail (~ 50%) with the error.  If I
> slow
> down the rate at which the ls is executed, I have a better chance at
> mounting all of the filesystems.  When I operate on chucks of the =
nodes
> 128 at a time, I can usually get them to mount ok.
>=20
> In the messages file I get:
>=20
> Jan 16 16:58:51 g0427 automount[537]: attempting to mount entry
> /misc/scratchx
> Jan 16 16:59:12 g0427 automount[13130]: >> mount: RPC: Timed out
> Jan 16 16:59:12 g0427 automount[13130]: mount(nfs): nfs: mount failure
> x00:/export/scratch1 on /misc/scratchx
>=20
> I tried increasing timeo to 30 and 60, and this appeared to help it
> did not fix the problem.  I never change timeo before.
>=20
> When the mounts do fail, I try and clean them up with umount.  Often
> when doing this I will get error messages on some of the nodes:
>=20
>   Bad UMNT RPC: RPC: Timed out
>=20
> This problem can be reduced when I do not have the umount execute on
> all of the nodes at the same time.
>=20
> This happens with when the filesystem is ext3 or xfs.
>=20
> I do not have these problems under the 2.4.14 kernel.
>=20
> Are there some timing values in RPC that have changed or that I can
> change
> to increase timeouts?  Does anyone have any other ideas?
>=20
> Thanks,
> Craig
>=20
> --=20
> David B. Ritch
> High Performance Technologies, Inc.
>=20
>=20
> --__--__--
>=20
>=20
>=20
>=20
>=20
>=20


-------------------------------------------------------
This SF.NET email is sponsored by: Thawte.com
Understand how to protect your customers personal information by implementing
SSL on your Apache Web Server. Click here to get our FREE Thawte Apache 
Guide: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0029en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: Stale mounts - very nasty
Date: Wed, 14 May 2003 09:04:56 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B916A32939@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailman2.ppco.com ([138.32.33.140])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Fwsj-000253-00
	for <nfs@lists.sourceforge.net>; Wed, 14 May 2003 07:05:21 -0700
Received: from bvlw2k131.ppco.com (trend1.ppco.com [138.32.31.131])
	by mailman2.ppco.com (8.12.8/8.12.8) with SMTP id h4EE5I4P020379
	for <nfs@lists.sourceforge.net>; Wed, 14 May 2003 09:05:18 -0500
Received: from hoexbh2.conoco.net (HOEXBH2.conoco.net [144.46.83.12])
	by mail1.ppco.com (8.11.6+Sun/8.11.6) with ESMTP id h4EE5Iu16114
	for <nfs@lists.sourceforge.net>; Wed, 14 May 2003 09:05:18 -0500 (CDT)
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

Guys,

I have one of these, where it went into this state in the middle of a =
copy,
ie part of the a file got copied and then the nfs partition when into =
this broken
state, all with the server doing nothing bad.

And I have now confirmed that it does it against Sun Solaris 8 servers, =
which
makes it look like a client problem, and not a server problem.

Any ideas on what is going on?  I cannot see any configuration mistake =
that
should cause this sort of behaviour under any conditions.

                              Roger

> "Heflin, Roger A." wrote:
> >=20
> > Basic problem:
> > stale nfs file handles.
> >=20
> > Conclusion:
> >=20
> > It looks like when the automounter umounts and if the server does =
not register
> > a "rpc.mountd: authenticated unmount request from" we get into this =
situation,
> > at least on a unused file systems.  I am not exactly sure what is =
happening
> > on the used filesystems.  This is on a high traffic setup with lots =
of mounts
> > and umounts and many many nodes, so given the high volume of =
mount/umounts
> > I would expect some requests to be dropped.
> >=20
> > It looks like when a umount is being done and the server is down or =
does not
> > confirm the umount that the client does not retry the umount and =
this
> > situation occurs, the situation is explained below.
> >=20
> > Does the above seem plausable?
> >=20
> > More information:
> >=20
> > Basic information, client is 2.4.21pre4 NFSALL (and 2.4.19 NFSALL), =
nfsutils
> > 1.0.1-1.
> >=20
> > When doing a df command we get this message in the messages file:
> >=20
> > nfs_statfs: statfs error =3D 116
> >=20
> > And the df looks like:
> >=20
> > hostname:/usr/applinux    0    1    0   0% /tmpmnt/usr/applinux
> >=20
> > Doing a umount /tmpmnt/usr/applinux fixes the problem (automounter =
remounts
> > it correctly).  I have had the problem happen with both automounter =
and fstab
> > mounted file systems, and I have had it happen with a Solaris 8 =
machine as
> > the server, so that argues to me that this is a client problem and =
not a
> > server problem. I have had it happen on  both 2.4.19 NFSALL and =
2.4.21pre4
> > NFSALL clients.
> >=20
> > The problem seems to happen without the server or obvious network =
issues going
> > on, though the problem also happens if the server reboots.   The =
server in
> > this case would be 2.4.19 NFSALL, and the mount entry is:
> >=20
> > hostname:/usr/applinux /tmpmnt/usr/applinux nfs rw,v3,
> > rsize=3D8192,wsize=3D8192,hard,intr,udp,lock,addr=3Dhostname 0 0
> >=20
> > It seems to happen quite a lot if the server reboots (a few out of a =
lot
> > of nodes have the issue), with a umount being required to fix it.  =
It does
> > not happen on all nodes (that we can tell, but it may happen on all =
nodes
> > that try to umount the down filesystem), just on some of the nodes.
> > It also will happen with the  client and server both up and ok =
without any
> > warning and without the server  rebooting or having anything funny =
done on it,
> > and it will only affect some  (1 usually) node.  I have had it do =
this while
> > the filesystems is being actively used (process have the fs open), =
in this case
> > the processes have to be killed and  then I umount the filesystems.
> >=20
> > It looks like a client problem of some sort, the network should be =
relatively
> > clean.
> >=20
> >                                                         Roger
>=20


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

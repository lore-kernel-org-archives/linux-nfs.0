From: Bernd Schubert <bernd-schubert@web.de>
Subject: nfsprog support
Date: Thu, 15 Apr 2004 17:50:39 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200404151750.53209.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BE98l-00069m-6Q
	for nfs@lists.sourceforge.net; Thu, 15 Apr 2004 08:50:59 -0700
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BE98k-0002zB-GE
	for nfs@lists.sourceforge.net; Thu, 15 Apr 2004 08:50:58 -0700
Received: from euklid.pci.uni-heidelberg.de (euklid.pci.uni-heidelberg.de [129.206.21.104])
	by relay.uni-heidelberg.de (8.12.10/8.12.10) with ESMTP id i3FFosni029697
	for <nfs@lists.sourceforge.net>; Thu, 15 Apr 2004 17:50:55 +0200 (MET DST)
Received: from bernd by euklid.pci.uni-heidelberg.de with local (Exim 3.35 #1 (Debian))
	id 1BE98f-0003Vl-00
	for <nfs@lists.sourceforge.net>; Thu, 15 Apr 2004 17:50:53 +0200
To: nfs@lists.sourceforge.net
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

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello,

about a year ago I already asked about nfsprog support and that time Trond
told me that the kernel doesn't support it yet.

Background: We are using both, the ClusterNFSD and the KNFSD on our server
(/etc and /var by the cNFSd and everything else by the knfsd).
Since ClusterNFS is based on unfsd, which only supports NFSv2, we were able
work around the nfsprog problem by simply using knfs for nfsv3 and clustern=
fs
for nfsv2. However, now we would like to use unfs3, but wouldn't like to
switch knfs to NFSv2.

I already looked into the source and it was pretty easy to add nfsprog supp=
ort
by adding a nfsprog variable to the mount structure. However I guess
something like this will never go into the kernel.
Then I tried to figure out how the mountprog variable is read from the kern=
el,
unfortunality I only found out that the fs/nfs/mount_clnt.c isn't even
compiled. So I can only guess that this somehow works via the get_mountport=
()
function from userspace, but so far I didn't find out which kernel functions
are responsible for that.

Can someone help me and tell me what would be the best way to add nfsprog
support to the kernel?


Thanks in advance,
	Bernd


PS: Our diskless environment based on ClusterNFS+KNFS really works pretty w=
ell
for more than one year and we only need to reboot the clients in case of an
kernel, glibc or init update. I'm currently writing a howto for that.


=2D --
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de

=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAfq9VC8BUnAF+ydYRAm7bAJ9eUDSnkyWe7ph7invkXv758PxMCwCggfit
2dqBPsaimV9d6TR5exHaLPo=3D
=3DBKVI
=2D----END PGP SIGNATURE-----


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

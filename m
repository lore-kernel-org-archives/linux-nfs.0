From: "Lever, Charles" <cel@netapp.com>
Subject: RE: RHEL3 Update 1 and NetApp NFS freeze issues
Date: Fri, 10 Sep 2004 07:28:33 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07E0B@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5mQK-0006Kn-Dc
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 07:30:48 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C5mQE-0004f8-EF
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 07:30:43 -0700
To: "John Nitis" <jnitis@ati.com>
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

> Previous to switching to NFS via TCP the "retrans" counter=20
> shown via nfsstat was an extremely high percentage of total=20
> rpc calls.

so now that you are mounting using TCP, the retrans counter remains
flat?

with UDP, this could be either: the network environment is causing
packet loss, or the servers are often responding more slowly than the
estimated RPC RTT (which is typical for loaded filers).

both cases are helped by switching to TCP.  i assume that's why you
switched.  can you describe your network environment to us so we get a
fuller picture?  link speeds, duplex setting, switch or router models,
etc.

> In this case the machines which crash=20
> are Opteron boxes with Broadcom NICs using the tg3 driver. =20
> We have RHEL3 Intel Xeon machines which don't exhibit this=20
> problem as well as hundreds of RH7.2/7.3 clients which don't=20
> exhibit the problem.

if only the Opteron/tg3 systems exhibit this problem, then i would
suggest hunting for a problem with the tg3 driver or for compatibility
issues between your NICs and your switch.  are the Opteron systems SMP?

i second steve's recommendation to enable SysRq and capture a thread
traceback.  there's already a line in /etc/sysctl.conf that you can use
to enable it automatically after every reboot.

  # Controls the System Request debugging functionality of the kernel
 =20
  kernel.sysrq =3D 1

is what mine looks like.

> I've searched the list and seen much talk of NFS patches and=20
> whatnot, would any of these be helpful to us?

so far it sounds like a networking problem, not an NFS problem.


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

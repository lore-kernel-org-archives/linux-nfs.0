From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Pb of optimization for a Cluster under Gigabit
Date: Wed, 7 Apr 2004 13:58:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DEAA@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBK7y-0001FH-Tk
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 13:58:30 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBK7y-0000ad-Kk
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 13:58:30 -0700
To: "Didier CONTIS" <didier@ece.gatech.edu>
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

> >do you really need to use the "sync" mount option on
> >the clients?  the "sync" export option on the server
> >should be enough for most applications.
>=20
> That definitely helped. Now the NFS options passed
> via automount to the client are:
>=20
> rw,nfsvers=3D3,udp,hard,intr,rsize=3D8192,wsize=3D8192
>=20
> However, the load of the nfs server still goes up to 3.5

that may be completely normal.

i don't think the load average is a good indication of
how hard your server is working.  is your application
throughput reasonable?  any response time problems?

you should talk a walk through the NFS HOWTO, as it has
some good server performance tips.

  http://nfs.sourceforge.net/


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

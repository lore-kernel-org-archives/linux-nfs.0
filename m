From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfs hang, acutaully really slow
Date: Thu, 6 May 2004 12:44:50 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DFDC@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLonn-00073X-Bi
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 12:45:03 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLonn-0003mk-3q
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 12:45:03 -0700
To: "Maxwell Bottiger" <sleepylight@jive-turkey.net>,
        <nfs@lists.sourceforge.net>
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

hi maxwell-

> 	I'm running some version of NFSv3.  I have whatever=20
> came packaged=20
> along with Fedora Core 1.  (They put their own version number on the=20
> package)
>=20
> 	My server appears to be running into a real problem transfering=20
> files.  As long as my transfers are super small (like ls)=20
> then everything=20
> is cool.  As soon as I try to work on bigger files (greater=20
> than 4k) most=20
> everything grinds to a screetching halt.  I can see that=20
> there is still=20
> activity, but the transfers are in terms of 3 or 4 packets every few=20
> seconds.  I've sort of been hobbling along using scp (wich is runing=20
> somewhere between 1000x to 1000000x faster than NFS right=20
> now) but that=20
> only works for so long.
>=20
> 	Where do I start trying to solve this problem?  I haven't been=20
> able to find any error messages.  Any help is greatly appreciated.

these are the classic symptoms of a network issue; probably
a speed or duplex mismatch in the network between your clients
and server.  if you switch to NFS over TCP, the problem will
likely go away.


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

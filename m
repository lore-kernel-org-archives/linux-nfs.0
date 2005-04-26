From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Client sees delay  in io when nfs server starts after failover
Date: Tue, 26 Apr 2005 07:03:54 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539A30@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQQfL-0008BW-4V
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 07:03:55 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DQQfK-0001vf-QW
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 07:03:55 -0700
To: "mehta kiran" <kiranmehta1981@yahoo.com>
Sender: nfs-admin@lists.sourceforge.net
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

>     I am using sles9 sp1 rc5 (2.6.5-7.139 kernel)
>     NFS server is running on a machines.
>     Client access server and does moderate amount=20
>     of io on mounted filesystem.
>     When nfs server switches to other machine ,=20
>     nfs client has to wait for 2-3 minutes so as
>     to continue io on new nfs server.
>     Sometimes client sees delay of  20-30
>     seconds only.Why is this difference seen in
>     different runs/executions.
>   =20
>     Is this the expected behaviour ?

i'm speculating, but i expect the delay is due to the time it takes the
client TCP layer to reconnect to the new server host.  i notice when a
client loses a TCP connection to a server (even without a failover) it
takes as long as 2-3 minutes to reconnect.  it's on my list of things to
look at improving.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

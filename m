From: Perceval Anichini <perceval.anichini@laposte.net>
Subject: RE: NFS : open is failing too slowly...
Date: 23 Jan 2004 16:23:32 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1074871427.16793.17.camel@ambre>
References: <482A3FA0050D21419C269D13989C611302B07B3F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ak3CT-0007Co-J3
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 07:26:25 -0800
Received: from avelizy-105-1-1-5.w80-11.abo.wanadoo.fr ([80.11.79.5] helo=ambre.maneex)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1Ak3CS-0007x9-UQ
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 07:26:25 -0800
Received: from ambre.maneex
	([127.0.0.1] helo=localhost.localdomain ident=corwin)
	by ambre.maneex with esmtp (Exim 3.35 #1 (Debian))
	id 1Ak39v-0004jr-00
	for <nfs@lists.sourceforge.net>; Fri, 23 Jan 2004 16:23:47 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07B3F@lavender-fe.eng.netapp.com>
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

	First of all, thanks for your answer !

> in general there is no way for a client to indicate to an application
> that it is no longer in touch with a server.
	Ok.

> if you are using UDP, then you don't need the timeo= option at all.
> the read and write retransmit timeout is set by the RPC client, and
> usually is much faster than a tenth of a second.
	I am effectively using UDP.

Thanks for the information. What lead me in error is the "man nfs"
page which said the default value is 7 tenth of a second.

> if you are using TCP, then timeo=1 is also not advisable.  this will
> cause the RPC and TCP layers to generate competing retransmissions,
> which wastes resources.
	Ok.

> retrans=1 with soft is an open invitation for silent data corruption.
> i highly encourage you not to do this.
	Ok. I'll put back retrans=3.

> you really don't want soft either.  rather, using "hard" instead will
> guarantee that the client will continue to retry your writes until the
> server is back up.  no data will be lost unless the client crashes.
> if you write() but don't flush() the file, your application should not
> hang during a normal write() until the client has filled its memory.
	That can be real fast, as i'm recording a bunch of video streams
encoded in MPEG2 :) That's why i really want to switch on the local hard
drive.

> if your file server is so unreliable that this is even an issue, then
> you have a problem with your server, and not in your application.  if
> you are concerned about the application becoming unresponsive, then
> you should consider using threads or nonblocking I/O.
	The NFS server is really reliable (According to your email, thanks)
The problem is that i don't want to loose datas !!! (If even one occurs)
So if the server have to shut down (even for a few minutes), I must be
able to continue the recording.



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

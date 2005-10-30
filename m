From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: regarding nfs configuration
Date: Sun, 30 Oct 2005 03:06:54 -0800 (PST)
Message-ID: <20051030110654.80142.qmail@web51607.mail.yahoo.com>
References: <951c25610510270333j62173c46q2228447338177af0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EWB1k-00009D-5e
	for nfs@lists.sourceforge.net; Sun, 30 Oct 2005 03:07:04 -0800
Received: from web51607.mail.yahoo.com ([206.190.38.212])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EWB1i-0006wq-E2
	for nfs@lists.sourceforge.net; Sun, 30 Oct 2005 03:07:04 -0800
To: Rajesh kumar <rishi.rajesh@gmail.com>, nfs@lists.sourceforge.net
In-Reply-To: <951c25610510270333j62173c46q2228447338177af0@mail.gmail.com>
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

Looks like you have not started mountd on
server side. This error is thrown when there
is no entity on server side listening for=20
connections.

Can you send output of following on client
#rpcinfo -p <nfs server name>

thanks,
 kiran

--- Rajesh kumar <rishi.rajesh@gmail.com> wrote:

> Respected .............
>=20
> I am using redhat 9 OS
> i have completed the nfs configuration at server
> side. while mounting
> from the client side i am facing the follwing error.
> mount: RPC: Remote system error - Connection refused
>=20
> kindly tell me the solution to the problem
>=20
> With Regards
> Rajesh Sharma
>=20
>=20
>
-------------------------------------------------------
> This SF.Net email is sponsored by the JBoss Inc.
> Get Certified Today * Register for a JBoss Training
> Course
> Free Certification Exam for All Training Attendees
> Through End of 2005
> Visit http://www.jboss.com/services/certification
> for more information
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20



	=09
__________________________________=20
Yahoo! FareChase: Search multiple travel sites in one click.
http://farechase.yahoo.com


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Shane Warren" <shanew@innovsys.com>
Subject: RE: NFS: Access Denied after Sever Reboot (on 2.6)
Date: Fri, 28 Oct 2005 11:43:51 -0500
Message-ID: <DCEAAC0833DD314AB0B58112AD99B93BA3007F@ismail.innsys.innovsys.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVXKg-00048R-8J
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 09:43:58 -0700
Received: from smtp.innovsys.com ([66.115.232.196] helo=mail.innovsys.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EVXKg-0003Ye-4Z
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 09:43:58 -0700
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

Ok, thanks for the help.  It turns the order I was starting the various =
nfs daemons and mounting the nfsd proc mount was incorrect.

-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
Sent: Friday, October 28, 2005 11:15 AM
To: Shane Warren
Subject: RE: [NFS] NFS: Access Denied after Sever Reboot (on 2.6)


fr den 28.10.2005 klokka 09:40 (-0500) skreiv Shane Warren:
> Ok here's the exchange when doing a ls -l on mounted share after a =
reboot.

Hmm... Apart from the server response, it looks OK to me. The reason I
was confused was that you mentioned "authentication set to none". In
fact there is authentication there: the client is using the standard
auth_sys/auth_unix with a credential that represents the standard "root"
setup.

>From looking at the code, though (I tend to do client only so it's
slightly unfamiliar), the Linux NFS server appears to reply with "bad
credential" whenever 'mountd' doesn't recognise your client as being
authorised.
That points another finger in the direction of the startup scripts.

Cheers,
 Trond

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Friday, October 28, 2005 9:37 AM
> To: Shane Warren
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] NFS: Access Denied after Sever Reboot (on 2.6)
>=20
>=20
> fr den 28.10.2005 klokka 09:17 (-0500) skreiv Shane Warren:
> > I have packet sniffed (w/ tcpdump and loading the dump in ethereal)
> > the messages the server gets/sends when the client gets the "access
> > denied" (when listing the shared directory), the exchange is =
something
> > like:
> > =20
> > client sends: GETATTR on a certain inode with authentication set to:
> > none
> > server responds: reject state set to: AUTH_ERROR, auth state set to:
> > Bad Credential (seal broken)
>=20
> Could you send me a binary tcpdump of this exchange, please? The =
client
> should never be sending anything with an AUTH_NULL credential.
>=20
> As for the server issue, have you checked that the 'nfsd' filesystem =
is
> being properly mounted, and that none of the scripts are calling
> exportfs after mountd has started?
>=20
> Cheers,
>   Trond
>=20
>=20




-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

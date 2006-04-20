From: "Tony" <tony@games-master.co.uk>
Subject: RE: Newbie NFS permissions question.
Date: Thu, 20 Apr 2006 10:09:19 +0100
Message-ID: <200604200906.k3K96LXx015413@main.games-master.co.uk>
References: <200604191447.k3JElkPE008657@main.games-master.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FWVAY-0007xV-H2
	for nfs@lists.sourceforge.net; Thu, 20 Apr 2006 02:09:46 -0700
Received: from [213.253.152.202] (helo=main.games-master.co.uk)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FWVAW-0004Ga-Hi
	for nfs@lists.sourceforge.net; Thu, 20 Apr 2006 02:09:46 -0700
To: "'Tony'" <tony@games-master.co.uk>,
	"'Steve Dickson'" <SteveD@redhat.com>
In-Reply-To: <200604191447.k3JElkPE008657@main.games-master.co.uk>
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

I've now got 2 new servers and have been able to NFS mount a share from=0A=
server 1 to server 2.=0A=
I can chmod, chown and chgrp of files and directories on server 2 as long as=
=0A=
the user and group exist on server 1.=0A=
Is this the default behaviour for NFS?=0A=
Does the user and group have to exist on the server sharing?=0A=
Is there a way of being able to change the ownership of a file or directory=
=0A=
without the user or/and group having to exist on the server allowing the=0A=
share?=0A=
=0A=
Thanks=0A=
Tony=0A=
=0A=
-----Original Message-----=0A=
From: nfs-admin@lists.sourceforge.net=0A=
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Tony=0A=
Sent: 19 April 2006 15:51=0A=
To: 'Steve Dickson'=0A=
Cc: nfs@lists.sourceforge.net=0A=
Subject: RE: [NFS] Newbie NFS permissions question.=0A=
=0A=
Looks like I'm running version 3.=0A=
I'll try the 'no_root_squash' option, just installing 2 new boxes so I'll=
=0A=
try it on them.=0A=
=0A=
Thanks=0A=
Tony=0A=
=0A=
-----Original Message-----=0A=
From: nfs-admin@lists.sourceforge.net=0A=
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Steve Dickson=0A=
Sent: 19 April 2006 14:41=0A=
To: Tony=0A=
Cc: nfs@lists.sourceforge.net=0A=
Subject: Re: [NFS] Newbie NFS permissions question.=0A=
=0A=
=0A=
=0A=
Tony wrote:=0A=
> I've used NFS in the past but only for file sharing, but now I need to=20=
=0A=
> use it in a live environment for uses email/web etc across load balanced=
=20=0A=
> servers.=0A=
>=20=0A=
> The problem I have is that the maildirs have to be owned by the user=20=
=0A=
> they belong to as does the web content.=0A=
>=20=0A=
> However when I mount an NFS share on both servers it's mounted as root=20=
=0A=
> with full permissions.=0A=
What NFS version are you using 2, 3 or 4?=0A=
=0A=
>=20=0A=
> The problem is every file/directory created in the mounted NFS share is=
=20=0A=
> also created owned by root, even when I try to change the permission to=
=20=0A=
> a different owner or try to chmod a file or directory it doesn't do=20=0A=
> anything.=0A=
Setting the 'no_root_squash' export option on the server might help...=0A=
=0A=
steved.=0A=
=0A=
=0A=
-------------------------------------------------------=0A=
Using Tomcat but need to do more? Need to support web services, security?=
=0A=
Get stuff done quickly with pre-integrated technology to make your job=0A=
easier=0A=
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo=
=0A=
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=120709&bid&3057&dat=121642=0A=
_______________________________________________=0A=
NFS maillist  -  NFS@lists.sourceforge.net=0A=
https://lists.sourceforge.net/lists/listinfo/nfs=0A=
=0A=
--=20=0A=
This message has been scanned for viruses and=0A=
dangerous content by MailScanner, and is=0A=
believed to be clean.=0A=
=0A=
=0A=
=0A=
--=20=0A=
This message has been scanned for viruses and=0A=
dangerous content by MailScanner, and is=0A=
believed to be clean.=0A=
=0A=
=0A=
=0A=
-------------------------------------------------------=0A=
Using Tomcat but need to do more? Need to support web services, security?=
=0A=
Get stuff done quickly with pre-integrated technology to make your job=0A=
easier=0A=
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo=
=0A=
http://sel.as-us.falkag.net/sel?cmd_________________________________________=
=0A=
______=0A=
NFS maillist  -  NFS@lists.sourceforge.net=0A=
https://lists.sourceforge.net/lists/listinfo/nfs=0A=
=0A=
=0A=
--=20=0A=
This message has been scanned for viruses and=0A=
dangerous content by MailScanner, and is=0A=
believed to be clean.=0A=
=0A=


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: query required
Date: Thu, 23 Feb 2006 05:46:32 -0800 (PST)
Message-ID: <20060223134632.42832.qmail@web51612.mail.yahoo.com>
References: <001a01c6387a$1e166eb0$027d0297@hcl01>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCGnq-0002aM-Ld
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 05:46:42 -0800
Received: from web51612.mail.yahoo.com ([68.142.224.85])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FCGnp-0006En-A0
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 05:46:42 -0800
To: Abhishek <abhimal@hcl.in>, nfs@lists.sourceforge.net
In-Reply-To: <001a01c6387a$1e166eb0$027d0297@hcl01>
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

1. You can see output of rpcinfo -p to see all the
   versions of nfs on your system.
2. nfsstat -s will give you list of calls being made.
   From this you can find active nfs server version.
   Similarly for client you can use nfsstat -c
3.You can mount by using nfsvers option of mount=20
  command to use specific nfs version

--- Abhishek <abhimal@hcl.in> wrote:

> HI,
>      I have questions regarding NFS,=20
>=20
> 1.)  How to find which version of NFS am I using.
>=20
> 2.) How to switch from one version to other version.
>=20
> Rgds,
>=20
> Abhishek


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

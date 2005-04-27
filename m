From: Neil Horman <nhorman@redhat.com>
Subject: Re: help with nfs
Date: Wed, 27 Apr 2005 08:10:06 -0400
Message-ID: <20050427121006.GB3305@hmsendeavour.rdu.redhat.com>
References: <3dd7287a05042205554e966492@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQlN6-00024b-G3
	for nfs@lists.sourceforge.net; Wed, 27 Apr 2005 05:10:28 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DQlMm-0002wS-QS
	for nfs@lists.sourceforge.net; Wed, 27 Apr 2005 05:10:28 -0700
To: Alejandra <alejamilis@gmail.com>
In-Reply-To: <3dd7287a05042205554e966492@mail.gmail.com>
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

On Fri, Apr 22, 2005 at 09:55:37AM -0300, Alejandra wrote:
> I'm trying to share some directories using nfs, and although I've
> modified the hosts.allow,hosts.deny and export files as the tutorial
> says, it doesn't work. I'm working in a simple workgroup of four
> computers  - three of them have both w2k and Fedora Core 3.
> Nfs-utils : version 1.0.6-39
> Kernel: 2.6.9
> =20
> This is my /etc/export:
>=20
> #Archivos a compartir
>=20
> /exportaciones	192.168.1.21(rw) 192.168.1.15(rw) 192.168.1.48(rw)
>=20
> This is /etc/hosts.allow:
>=20
> portmap: 192.168.1.48 , 192.168.1.15 , 192.168.1.48
> lockd: 192.168.1.48 , 192.168.1.15 , 192.168.1.48
> mountd: 192.168.1.48 , 192.168.1.15 , 192.168.1.48
> rquotad: 192.168.1.48 , 192.168.1.15 , 192.168.1.48
> statd: 192.168.1.48 , 192.168.1.15 , 192.168.1.48
>=20
> This is /etc/hosts.deny:
>=20
> portmap:ALL
> lockd:ALL
> mountd:ALL
> rquotad:ALL
> statd:ALL
>=20
> The problem is that, when the client tries to mount /export, the
> following error apprears:
> <server not mounted>
>=20
They should be trying to mount:
<server_ip_address>:/exportaciones

not just /export.  Or were you paraphrasing there?
HTH
Neil

> I've strictly followed the instructions in the tutorial, but I cannot
> solve this problem, I hope you can help me.
>=20
> Thank you in advance
>=20
> Alejandra Jamilis
>=20
>=20
> -------------------------------------------------------
> SF.Net email is sponsored by: Tell us your software development plans!
> Take this survey and enter to win a one-year sub to SourceForge.net
> Plus IDC's 2005 look-ahead and a copy of this survey
> Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--=20
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

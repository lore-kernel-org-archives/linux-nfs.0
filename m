From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: query required
Date: Thu, 23 Feb 2006 14:43:26 +0100
Message-ID: <200602231443.26532.vincent.roqueta@ext.bull.net>
References: <001a01c6387a$1e166eb0$027d0297@hcl01>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "Abhishek" <abhimal@hcl.in>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCGiF-0001y7-Rz
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 05:40:55 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FCGiE-0003ja-7H
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 05:40:55 -0800
To: nfs@lists.sourceforge.net
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

Le Jeudi 23 F=E9vrier 2006 14:07, Abhishek a =E9crit=A0:
> HI,
>      I have questions regarding NFS,
>
> 1.)  How to find which version of NFS am I using.
type mount  -v on the client.
If version is not=20

> 2.) How to switch from one version to other version.
mount -t nfs -o nfsvers=3D2/3  server:/exported/directory /mount/point/


for nfs4
mount -t nfs4 server:/ /mount/point/


Vincent


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

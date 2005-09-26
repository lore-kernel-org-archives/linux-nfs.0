From: Reuti <reuti@staff.uni-marburg.de>
Subject: Re: [CIRCUMVENTED] NFS client got stale NFS handle after server
 reboot
Date: Mon, 26 Sep 2005 10:32:55 +0200
Message-ID: <4337B237.9000706@staff.uni-marburg.de>
References: <433027F7.1030702@staff.uni-marburg.de> <4332784C.8040503@staff.uni-marburg.de> <4332C52F.5000908@staff.uni-marburg.de> <200509221720.52412.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EJoQ0-000839-Vo
	for nfs@lists.sourceforge.net; Mon, 26 Sep 2005 01:33:00 -0700
Received: from vhrz24.hrz.uni-marburg.de ([137.248.1.34])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EJoQ0-0001uK-8P
	for nfs@lists.sourceforge.net; Mon, 26 Sep 2005 01:33:01 -0700
Received: from staff.uni-marburg.de (pc15218.Chemie.Uni-Marburg.DE [137.248.152.52])
	by vhrz24.hrz.uni-marburg.de (8.13.4/8.13.4/Debian-3) with ESMTP id j8Q8WtrC009096
	for <nfs@lists.sourceforge.net>; Mon, 26 Sep 2005 10:32:55 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <200509221720.52412.vincent.roqueta@ext.bull.net>
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

...and then this one.

Hi Vincent,

I had a short look into the source of nfs-utils, but I realized, that=20
most is in the kernel. But I saw a line checking for the DNS names and=20
sometimes skipping it (if all mount points are unexported).

And this was another thing: we don't have DNS in the cluster, but use=20
only the /etc/hosts file and distribute it to the nodes with NIS. And in=20
the rmtab file, I saw some entries with the nodename, and another one=20
with the TCP/IP address of the same node. Relies NFS on DNS in the new mo=
de?

Cheers - Reuti


Vincent Roqueta wrote:
> Le jeudi 22 Septembre 2005 16:52, Reuti a =E9crit :
>=20
>>Finally I could track down the odd behavior (this time in top posting):
>>
>>If you have this combination:
>>
>>+ Linux kernel 2.6 nfsd on server
>>+ 64 bit i386, i.e. x86_64 server
>>+ using netgroups in /etc/exports
>>+ operate mountd/exportfs in new mode
>>
>>you will face the problem of stale NFS handle after a stop/start of of
>>the NFS service. As we want to use 64 bit of course, and enjoy netgroup=
s
>>for easier administration, I got a working setup by *not* mounting
>>/proc/fs/nfsd and forcing this way mountd/exportfs into legacy mode als=
o
>>on a 2.6 kernel.
>>
>>Cheers - Reuti
>=20
>=20
>=20
> There are several problems using x86_64 linux NFS (v4) machines as serv=
er, and=20
> it seems to have several problems on 64 bits architectures in general (=
at=20
> least with x86_64 and ppc64. Surely other architectures)
> =20
> For now there are this issue yet known (linux 2.6.13+CITI, Linux 2.6.14=
-rc*=20
> +CITI)
> -> Socket error -11 closing a big file (server : x86_64, clients: x86, =
ppc64)
> -> wrong lock behaviours  (Client PPC64, servers: ppc64, x86)
> ->  Input/output error closing a big file (server: ppc64, client x86_64=
)
> -> Oops (Client x86_64, server x86_64) - Linux 2.6.13+CITI
>=20
> However, this issues concern NFSv4. I am going to try to reproduce your=
=20
> problem with NFSv3 and NFSv4.
>=20
>=20
> Vincent
>=20
>=20
> -------------------------------------------------------
> SF.Net email is sponsored by:
> Tame your development challenges with Apache's Geronimo App Server.=20
> Download it for free - -and be entered to win a 42" plasma tv or your v=
ery
> own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.p=
hp
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: [CIRCUMVENTED] NFS client got stale NFS handle after server reboot
Date: Thu, 22 Sep 2005 17:20:52 +0200
Message-ID: <200509221720.52412.vincent.roqueta@ext.bull.net>
References: <433027F7.1030702@staff.uni-marburg.de> <4332784C.8040503@staff.uni-marburg.de> <4332C52F.5000908@staff.uni-marburg.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EISpz-00069B-EZ
	for nfs@lists.sourceforge.net; Thu, 22 Sep 2005 08:18:15 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EISpx-0005gO-A5
	for nfs@lists.sourceforge.net; Thu, 22 Sep 2005 08:18:15 -0700
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 3EF7619D909
	for <nfs@lists.sourceforge.net>; Thu, 22 Sep 2005 17:17:27 +0200 (CEST)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 20508-04 for <nfs@lists.sourceforge.net>;
 Thu, 22 Sep 2005 17:17:25 +0200 (CEST)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 4CDFC19D907
	for <nfs@lists.sourceforge.net>; Thu, 22 Sep 2005 17:17:25 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <4332C52F.5000908@staff.uni-marburg.de>
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

Le jeudi 22 Septembre 2005 16:52, Reuti a =E9crit=A0:
> Finally I could track down the odd behavior (this time in top posting):
>
> If you have this combination:
>
> + Linux kernel 2.6 nfsd on server
> + 64 bit i386, i.e. x86_64 server
> + using netgroups in /etc/exports
> + operate mountd/exportfs in new mode
>
> you will face the problem of stale NFS handle after a stop/start of of
> the NFS service. As we want to use 64 bit of course, and enjoy netgroups
> for easier administration, I got a working setup by *not* mounting
> /proc/fs/nfsd and forcing this way mountd/exportfs into legacy mode also
> on a 2.6 kernel.
>
> Cheers - Reuti


There are several problems using x86_64 linux NFS (v4) machines as server, =
and=20
it seems to have several problems on 64 bits architectures in general (at=20
least with x86_64 and ppc64. Surely other architectures)
=20
=46or now there are this issue yet known (linux 2.6.13+CITI, Linux 2.6.14-r=
c*=20
+CITI)
=2D> Socket error -11 closing a big file (server : x86_64, clients: x86, pp=
c64)
=2D> wrong lock behaviours  (Client PPC64, servers: ppc64, x86)
=2D>  Input/output error closing a big file (server: ppc64, client x86_64)
=2D> Oops (Client x86_64, server x86_64) - Linux 2.6.13+CITI

However, this issues concern NFSv4. I am going to try to reproduce your=20
problem with NFSv3 and NFSv4.


Vincent


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

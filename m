From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: mounting NFS with TCP option
Date: Tue, 7 Mar 2006 16:12:56 +0100
Message-ID: <200603071612.56819.vincent.roqueta@ext.bull.net>
References: <a9ed420f0603070703x7a864804h9e6e2786b6dcdd19@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FGdpL-0008BO-P7
	for nfs@lists.sourceforge.net; Tue, 07 Mar 2006 07:10:19 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FGdpJ-0001yv-RW
	for nfs@lists.sourceforge.net; Tue, 07 Mar 2006 07:10:19 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 6059219D90E
	for <nfs@lists.sourceforge.net>; Tue,  7 Mar 2006 16:09:46 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 04041-01 for <nfs@lists.sourceforge.net>;
 Tue,  7 Mar 2006 16:09:45 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id C64AB19D906
	for <nfs@lists.sourceforge.net>; Tue,  7 Mar 2006 16:09:44 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <a9ed420f0603070703x7a864804h9e6e2786b6dcdd19@mail.gmail.com>
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

Le Mardi 7 Mars 2006 16:03, Vijay Chauhan a =E9crit=A0:
> Hi,
> im mounting a remote file system like this:
> while [ "a" =3D=3D "a" ];
> do
> mount -t nfs -o tcp server:/file-system-path /mnt-point
> umount -at nfs
> done
>
> after few mounts it stop mounting the file system.
>
> Can anyone give any hints/suggestion
> Also does tcp have any effect in this case?
>
> TIA,
> Vijay

To many port used?
Each time you perform a mount with NFSv3 you open a new tcp port. if there =
is=20
no more tcp port avalaible, mount fails.


Vincent


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

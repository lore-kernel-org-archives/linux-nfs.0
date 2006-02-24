From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: Info needed for Development and troubleshooting NFS3 server on Linux 2.6.5+ kernel
Date: Fri, 24 Feb 2006 15:38:52 +0100
Message-ID: <200602241538.52625.vincent.roqueta@ext.bull.net>
References: <5640edcd0602232034pb497dfchb3e890397e124bf4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCe3T-0008Us-3j
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 06:36:23 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FCe3P-0001yq-3P
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 06:36:23 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 0965C19D913
	for <nfs@lists.sourceforge.net>; Fri, 24 Feb 2006 15:35:48 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 06410-06 for <nfs@lists.sourceforge.net>;
 Fri, 24 Feb 2006 15:35:46 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id AFABE19D907
	for <nfs@lists.sourceforge.net>; Fri, 24 Feb 2006 15:35:46 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <5640edcd0602232034pb497dfchb3e890397e124bf4@mail.gmail.com>
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

Le Vendredi 24 F=E9vrier 2006 05:34, Sree AR a =E9crit=A0:
> Hi,
>
> I would like to work on Linux 2.6.5+ kernel NFS3 server performance
> improvement.Basically I am a Windows guy and I don't know much about
> Debugging on Linux.
Ok. Is it mandatory to work on :
* NFSv3 instead of NFSv4 ?
* 2.6.5 kernels while we are working on latest 2.6.15+ kernels ?

> If anybody has NFS3 design documents plz share with me.=20
I am not sure such documents exist.
> Also plz send me the steps to Debug NFS3 server.
http://www.citi.umich.edu/projects/nfsv4/linux/nfsv4-hacking.html

Vincent


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

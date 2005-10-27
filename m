From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: regarding nfs configuration
Date: Thu, 27 Oct 2005 14:35:54 +0200
Message-ID: <200510271435.54673.vincent.roqueta@ext.bull.net>
References: <951c25610510270333j62173c46q2228447338177af0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EV6wV-00060q-GO
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 05:33:15 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EV6wT-00065N-OP
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 05:33:15 -0700
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id F1F3619DF06
	for <nfs@lists.sourceforge.net>; Thu, 27 Oct 2005 14:32:25 +0200 (CEST)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 00478-09 for <nfs@lists.sourceforge.net>;
 Thu, 27 Oct 2005 14:32:24 +0200 (CEST)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 468B819DF05
	for <nfs@lists.sourceforge.net>; Thu, 27 Oct 2005 14:32:24 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

Le Jeudi 27 Octobre 2005 12:33, Rajesh kumar a =E9crit=A0:
> Respected .............
>
> I am using redhat 9 OS
> i have completed the nfs configuration at server side. while mounting
> from the client side i am facing the follwing error.
> mount: RPC: Remote system error - Connection refused

Could you tel me results of=20
(server side)
exportfs -v=20
mount=20
lsmod (if nfs or nfsd are modularized)
kernel version (uname -a)

(Client side)
mount=20
options you are passing to mount


Vincent


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

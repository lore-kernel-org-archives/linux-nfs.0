From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: How to know whether a given directory in in NFS
Date: Thu, 2 Dec 2004 13:28:36 +0100
Message-ID: <200412021328.36317.vincent.roqueta@ext.bull.net>
References: <20041202121530.16871.qmail@web60307.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CZpyl-00024y-Vj
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 04:22:35 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CZpyk-0005KJ-Ej
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 04:22:35 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id B492319D909
	for <nfs@lists.sourceforge.net>; Thu,  2 Dec 2004 13:22:25 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 29385-08 for <nfs@lists.sourceforge.net>;
 Thu,  2 Dec 2004 13:22:23 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id A5F6819D907
	for <nfs@lists.sourceforge.net>; Thu,  2 Dec 2004 13:22:23 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <20041202121530.16871.qmail@web60307.mail.yahoo.com>
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

Le jeudi 2 D=E9cembre 2004 13:15, Raghu Ram Murthy a =E9crit=A0:
> How with mount.
>
> for example, /home directory is in NFS and /tmp is not
> in NFS and I don't know whether /home is in NFS or
> not?
>
> Then how can I find?



mount will return a line within:

nfs_server:/an/exported/directory/ on /home type nfs
or
nfs_server:/an/exported/directory/ on /home type nfs4

depending on the nfs version you are using.

You can parse the mount result. I don't know if there is an other way to kn=
ow=20
that?

Vincent


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: export very large filesystem
Date: Mon, 21 Nov 2005 16:07:23 +0100
Message-ID: <200511211607.23137.vincent.roqueta@ext.bull.net>
References: <4381DDBA.9090509@chrisdos.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EeDEv-0000OL-OO
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 07:05:53 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EeDEr-00060U-GD
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 07:05:53 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 4D04419DF04
	for <nfs@lists.sourceforge.net>; Mon, 21 Nov 2005 16:04:59 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 03201-01 for <nfs@lists.sourceforge.net>;
 Mon, 21 Nov 2005 16:04:57 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id AE0CD19D90A
	for <nfs@lists.sourceforge.net>; Mon, 21 Nov 2005 16:04:57 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <4381DDBA.9090509@chrisdos.com>
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

Le Lundi 21 Novembre 2005 15:46, Chris Dos a =E9crit=A0:
> I have a customer that would like to export their 22.5 TB XFS file system
> via NFS using Linux 2.6.14.  Before I even attempt to do this, can NFS
> v2/3/4 even handle something like this?


Yes!
http://nfsv4.bullopensource.org/tools/tests/page16.php

Vincent


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: Some interoperability testing
Date: Wed, 9 Feb 2005 11:20:54 +0100
Message-ID: <200502091120.54161.vincent.roqueta@ext.bull.net>
References: <200502071839.24804.vincent.roqueta@ext.bull.net> <1107874199.10364.22.camel@lade.trondhjem.org> <200502081643.34440.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cyosn-0000p1-Cx
	for nfs@lists.sourceforge.net; Wed, 09 Feb 2005 02:15:41 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cyosk-0000ss-Dk
	for nfs@lists.sourceforge.net; Wed, 09 Feb 2005 02:15:41 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id DDBD919D909
	for <nfs@lists.sourceforge.net>; Wed,  9 Feb 2005 11:14:54 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 24021-03 for <nfs@lists.sourceforge.net>;
 Wed,  9 Feb 2005 11:14:52 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id AABD419D907
	for <nfs@lists.sourceforge.net>; Wed,  9 Feb 2005 11:14:52 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <200502081643.34440.vincent.roqueta@ext.bull.net>
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

Le mardi 8 F=E9vrier 2005 16:43, Vincent Roqueta a =E9crit=A0:
> Le mardi 8 F=E9vrier 2005 15:49, Trond Myklebust a =E9crit=A0:
> > ty den 08.02.2005 Klokka 10:22 (+0100) skreiv Vincent Roqueta:
> > > Since all is right with kernel 2.6.9, that looks like a regression...
> > > Even if that is the true behaviour it may exist a way to stop this
> > > process cleanly : since NFS umount is can't be done the client does n=
ot
> > > reboot, and I need  to turn the power off...
> >
> > There were no NFS or RPC client changes made between 2.6.9 and 2.6.10,
>
> Well... Some littles changes :-)
>
> I tried various kernel and patches versions since this morning:
> linux-2.6.9 -> PASSED
> linux-2.6.10-rc1-CITI_NFS4_ALL-2.dif -> PASSED
> linux-2.6.10-rc1-CITI_NFS4_ALL-3.dif -> (answer soon)
> linux-2.6.10-rc1-CITI_NFS4_ALL-4.dif -> FAILED
>
> The problem is between in the NFS4_ALL-4.dif or NFS4_ALL-3.dif ...
>
>
> Vincent
>

Problem is in 2.6.10-rc2-CITI_NFS4_ALL-1 patch set

however  linux-2.6.10-rc1-CITI_NFS4_ALL-4.dif  patch set FAIL _some_ times.
I am investigating more to know what  patch is wrong.

Vincent


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

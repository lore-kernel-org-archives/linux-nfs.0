From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: Can someone explain me what this error means?
Date: Thu, 17 Mar 2005 17:37:19 +0100
Message-ID: <200503171737.19660.vincent.roqueta@ext.bull.net>
References: <4239A9A3.5000109@framestore-cfc.com> <1111075730.13215.19.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBxu4-0005jw-LO
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 08:31:20 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DBxu3-0003SO-2h
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 08:31:20 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id DDFA519D918
	for <nfs@lists.sourceforge.net>; Thu, 17 Mar 2005 17:31:07 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 06090-10 for <nfs@lists.sourceforge.net>;
 Thu, 17 Mar 2005 17:31:05 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 1A9F119D915
	for <nfs@lists.sourceforge.net>; Thu, 17 Mar 2005 17:31:05 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <1111075730.13215.19.camel@lade.trondhjem.org>
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

Le jeudi 17 Mars 2005 17:08, Trond Myklebust a =E9crit=A0:
> to den 17.03.2005 Klokka 16:00 (+0000) skreiv Johan van den Dorpe:
> > Mar 16 12:25:55 nyserv1 kernel: rpc-srv/tcp: nfsd: sent only 5160 bytes
> > of 8324 - shutting down socket
> >
> > We get this just before the machine becomes inaccessable from the
> > network.
>
> Is this an error from the kernel nfs daemon? If so, which kernel are you
> running, 'cos there is no such error message in Linux-2.6.11.
>
> Cheers,
>   Trond

HelloTrond,

The kernel is the 2.4.20, using the e1000 driver... That looks like the bug=
 I=20
had with UDP fragmentation? I used the same driver!

Vincent


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: FC3 <-> Solaris 10, NFSv4 interop?
Date: Fri, 25 Feb 2005 17:06:24 +0100
Message-ID: <200502251706.24315.vincent.roqueta@ext.bull.net>
References: <1109296629.5897.574.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4htt-0006ck-Rx
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 08:01:09 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D4hto-0001UY-3u
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 08:01:09 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id DBE2019D90F
	for <nfs@lists.sourceforge.net>; Fri, 25 Feb 2005 17:00:24 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 11759-09 for <nfs@lists.sourceforge.net>;
 Fri, 25 Feb 2005 17:00:22 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 840DA19D90A
	for <nfs@lists.sourceforge.net>; Fri, 25 Feb 2005 17:00:22 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <1109296629.5897.574.camel@seki.nac.uci.edu>
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

Le vendredi 25 F=E9vrier 2005 02:57, Dan Stromberg a =E9crit=A0:
> Has anyone got NFSv4 working from an FC3 NFS server to a Solaris 10 NFS
> client?
>
> foobar-root /) mount seki.nac.uci.edu:/sdb1 /mnt
> nfs mount: mount: /mnt: Not owner
> foobar-root /) mount -o vers=3D3 seki.nac.uci.edu:/sdb1 /mnt
> foobar-root /)

Yes. interop works fine.

Vincent


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

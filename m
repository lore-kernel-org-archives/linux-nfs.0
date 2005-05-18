From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: Extremely high load on NFS clients wen the NFS server is down...
Date: Wed, 18 May 2005 17:54:14 +0200
Message-ID: <200505181754.14362.vincent.roqueta@ext.bull.net>
References: <200505181429.j4IET8GK023074@s7.stat.tamu.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYQnr-0001Je-GX
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 08:49:47 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DYQno-0003OP-8Q
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 08:49:47 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <200505181429.j4IET8GK023074@s7.stat.tamu.edu>
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

Le mercredi 18 Mai 2005 16:28, Henrik Schmiediche a =E9crit=A0:
>     Hello,
> I have two Redhat AS3 servers. One of them (among other things) serves NFS
> file systems to my other systems including to the other server. When my N=
=46S
> file server goes down or is restarted the load on the other AS3 server
> increases to the point it is completely useless (it goes to 50+ in a minu=
te
> or two). I never observed this behavior when I was serving NFS file syste=
ms
> using a Solaris system.
>
> Has anyone observed this phenomenon?  Any solution to it?
Which process use so many CPU ? rpc.mountd ?


Cordialement,
Vincent


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

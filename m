From: "randy" <paries@knology.net>
Subject: RE: Redhat 9 tcpmounting
Date: Mon, 30 Aug 2004 07:53:45 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C1nil-0004L7-0H@sc8-sf-mx2.sourceforge.net>
References: <7E0DB3A126BA9146AC30744E2B7E4245111946@midhouhqxch01.net.smith.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1nim-0003eN-Km
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 08:05:24 -0700
Received: from smtp.knology.net ([24.214.63.101])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.34)
	id 1C1nil-0004L7-0H
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 08:05:24 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <7E0DB3A126BA9146AC30744E2B7E4245111946@midhouhqxch01.net.smith.com>
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

Does anyone know the option I would have to enable in the config when
building the kernel?

Also is there a enough performance gain to warrant recompiling the kernel?

Thanks for you help

Randy 



-----Original Message-----
From: Nelson, Allan [mailto:anelson@miswaco.com] 
Sent: Sunday, August 29, 2004 11:10 AM
To: randy
Subject: RE: [NFS] Redhat 9 tcpmounting

Yes, but you need to recompile the kernel to get support for it.
Allan

	-----Original Message----- 
	From: nfs-admin@lists.sourceforge.net on behalf of randy 
	Sent: Sun 8/29/2004 2:34 AM 
	To: nfs@lists.sourceforge.net 
	Cc: 
	Subject: [NFS] Redhat 9 tcpmounting
	
	

	 Hello
	
	Does anyone know if rh9 supports tcp mounting
	
	When I try I get the error
	nfs server reported service unavailable: Address already in use
	
	my servers
	cat /etc/exports
	/home/un/  192.168.0.214(insecure,rw)
	/home/unt   nfs.krusty(insecure,rw)
	/home/und    nfs.krusty(insecure,rw)
	
	
	
	
	-------------------------------------------------------
	This SF.Net email is sponsored by BEA Weblogic Workshop
	FREE Java Enterprise J2EE developer tools!
	Get your free copy of BEA WebLogic Workshop 8.1 today.
	http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
	_______________________________________________
	NFS maillist  -  NFS@lists.sourceforge.net
	https://lists.sourceforge.net/lists/listinfo/nfs
	
	


____________________________________________________________________________
__
This email is intended solely for the person or entity to which it is
addressed and may contain confidential and/or privileged information.
Copying, forwarding or distributing this message by persons or entities
other than the addressee is prohibited. If you have received this email in
error, please contact the sender immediately and delete the material from
any computer.  This email may have been monitored for policy compliance.
[021216]




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

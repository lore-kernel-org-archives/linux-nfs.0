From: "randy" <paries@knology.net>
Subject: Redhat 9 tcpmounting
Date: Sun, 29 Aug 2004 02:34:23 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C1KCq-0008Cp-6W@sc8-sf-mx1.sourceforge.net>
References: <E1C1K7k-0007dv-U5@sc8-sf-mx1.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1KCq-0005Ly-OT
	for nfs@lists.sourceforge.net; Sun, 29 Aug 2004 00:34:28 -0700
Received: from smtp.knology.net ([24.214.63.101])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.34)
	id 1C1KCq-0008Cp-6W
	for nfs@lists.sourceforge.net; Sun, 29 Aug 2004 00:34:28 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <E1C1K7k-0007dv-U5@sc8-sf-mx1.sourceforge.net>
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

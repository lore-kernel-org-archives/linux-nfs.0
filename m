From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: nfs & nfsd as modules
Date: Fri, 27 Feb 2004 14:27:18 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402271427.18626.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwiFb-0007VA-8q
	for nfs@lists.sourceforge.net; Fri, 27 Feb 2004 05:41:59 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwhyW-00018Q-MH
	for nfs@lists.sourceforge.net; Fri, 27 Feb 2004 05:24:21 -0800
Received: from roquetav (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id OAA19560
	for <nfs@lists.sourceforge.net>; Fri, 27 Feb 2004 14:24:56 +0100
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
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

Can't compile nfs et nfsd as modules.


adding to
fs/nfs4acl/acl_syms.c

EXPORT_SYMBOL(locks_remove_posix);
EXPORT_SYMBOL(nfs4_acl_posix_to_nfsv4);
EXPORT_SYMBOL(nfs4_acl_nfsv4_to_posix);



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: nfs as modules
Date: Fri, 27 Feb 2004 15:01:14 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402271501.14656.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwiZO-0004Pc-5m
	for nfs@lists.sourceforge.net; Fri, 27 Feb 2004 06:02:26 -0800
Received: from externalmx.valinux.com ([198.186.202.147] helo=externalmx.vasoftware.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwiII-0004H1-8i
	for nfs@lists.sourceforge.net; Fri, 27 Feb 2004 05:44:46 -0800
Received: from [129.183.4.3] (port=45227 helo=ecbull20.frec.bull.fr)
	by externalmx.vasoftware.com with esmtp (Exim 4.24 #1 (Debian))
	id 1AwiWw-0000DR-5C
	for <nfs@lists.sourceforge.net>; Fri, 27 Feb 2004 05:59:54 -0800
Received: from roquetav (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id OAA14246
	for <nfs@lists.sourceforge.net>; Fri, 27 Feb 2004 14:58:51 +0100
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


Can't compile nfs as modules.


adding to
/net/sunrpc/sunrpc_syms.c line 155

EXPORT_SYMBOL(read_bytes_from_xdr_buf);
EXPORT_SYMBOL(read_u32_from_xdr_buf);



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

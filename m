From: Sven Geggus <sven@geggus.net>
Subject: 2.4.21 NFS client Freezes :(
Date: Wed, 18 Jun 2003 15:42:39 +0000 (UTC)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <bcq19f$onn$1@benzin.geggus.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from benzin.geggus.net ([213.146.112.23] ident=foobar)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Sf5f-0007QX-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 08:43:15 -0700
Received: from news by benzin.geggus.net with local
	(Exim 4.20 id 19Sf55-0006ag-TX)
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 17:42:39 +0200
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi there,

when trying to access NFS volumes on a Windows Server (yes, these beasts
exist) my whole systems gets frozen (there are ping responces, but nothing  
more).
   
This is however working fine with 2.4.20 and can be reproduced on any
machine running 2.4.21!
   
The Server is a third Party tool called "NFS Maestro" from Hummingbird.

Any hints on how to further debug this?

The magic System request just told me that the ls command which caused the
hang is in running state.

Sven

-- 
"And I'm right.  I'm always right, but in this case I'm just a bit more
right than I usually am." (Linus Torvalds, Sunday Aug 27, 2000)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

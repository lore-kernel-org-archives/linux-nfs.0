From: myciel <myciel@dotcom.pl>
Subject: RPC: Unable to allocate ...
Date: Mon, 24 Mar 2003 11:24:10 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E7EDCCA.8060904@dotcom.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hub.interia.pl ([217.74.65.59])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18xP7S-0007cf-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Mar 2003 02:23:55 -0800
Received: from dotcom.pl (admini.te.interia.pl [10.33.3.10])
	by hub.interia.pl (Mailer) with ESMTP id A7DF328B0F
	for <nfs@lists.sourceforge.net>; Mon, 24 Mar 2003 11:23:45 +0100 (CET)
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

Hi

ocasionally (once or twice daily) I get hundreds of warnings during few 
seconds saying:
"RPC: Unable to allocate resbuf from cache!"

I've found in list archive suggestion to put more memory on server,
but my machine has already 1GB of ram. 

I run 2.4.18 + nfsall patches, 2 nfs filesystems of size 620GB and 420GB 
on top of reiserfs,
 80% filled with small files (average size 25kb) - any hints?

thanks

Rafal Mycielski




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

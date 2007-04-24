From: "Alexandre DELAY" <alexandre.delay@free.fr>
Subject: RE :  NFS with Dynamic IP clients
Date: Tue, 24 Apr 2007 22:30:57 +0200
Message-ID: <003501c786af$7746dcc0$0202a8c0@artemis>
References: <002801c786ab$e934cdf0$0202a8c0@artemis>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgRer-0006T7-CL
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 13:30:41 -0700
Received: from smtp1-g19.free.fr ([212.27.42.27])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgRer-0001X6-Od
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 13:30:44 -0700
Received: from Cerbere-de-Troyes.cerbere23.com (unknown [62.147.211.204])
	by smtp1-g19.free.fr (Postfix) with ESMTP id 9D4C8B929A
	for <nfs@lists.sourceforge.net>; Tue, 24 Apr 2007 22:30:39 +0200 (CEST)
Received: from artemis ([192.168.2.2])
	by Cerbere-de-Troyes.cerbere23.com (8.13.8/8.13.3) with ESMTP id
	l3OKU7NZ085257
	for <nfs@lists.sourceforge.net>; Tue, 24 Apr 2007 22:30:08 +0200 (CEST)
	(envelope-from alexandre.delay@free.fr)
In-Reply-To: <002801c786ab$e934cdf0$0202a8c0@artemis>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

>Hi
>I am searching for a solution to my problem.
>I have a fixed NFS server connected to Internet. 
>Clients (There will be ~300 NFS connected clients) have dynamic public IP
addresses.
>How can I setup my server and clients?
>Thanks
>Cheers
>Alex


Would it work with DynDNS names in exports file?


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Tiziana Manfroni <manfroni@mat.uniroma3.it>
Subject: lockd problem
Date: Tue, 26 Sep 2006 12:33:33 +0200 (CEST)
Message-ID: <Pine.OSF.4.58.0609261226340.71860@matrm3.mat.uniroma3.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSAIA-0007zK-Qc
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 03:35:58 -0700
Received: from mail.mat.uniroma3.it ([193.204.165.208])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GSAIA-0002kK-6e
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 03:35:59 -0700
Received: from matrm3.mat.uniroma3.it (matrm3.mat.uniroma3.it
	[193.204.165.131])
	by mail.mat.uniroma3.it (8.13.8/8.13.8) with ESMTP id k8QAcbZJ017433
	for <nfs@lists.sourceforge.net>; Tue, 26 Sep 2006 12:38:37 +0200
Received: from matrm3.mat.uniroma3.it (localhost [127.0.0.1])
	by matrm3.mat.uniroma3.it (8.13.8/8.13.8) with ESMTP id k8QAXX8D083014
	for <nfs@lists.sourceforge.net>; Tue, 26 Sep 2006 12:33:33 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

I have a NFSv4 server with kernel-2.6.13-1.1526_FC4smp on fedora4
Sometime I have an error on NFS server such as:
Sep 25 12:32:39 x.x.x.x kernel: RPC: error 5 connecting to server x.x.x.x
Sep 25 12:32:39 x.x.x.x kernel: lockd: couldn't create RPC handle for x.x.x.x
every one minutes. What is the problem?
When I restart nfs I have the same message so I can't kill it.
Do you have any idea to resolve these problems?

Thanks in advance

	Tiziana

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

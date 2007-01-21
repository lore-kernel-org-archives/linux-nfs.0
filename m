From: "james bardin" <jbardin@bu.edu>
Subject: nfs sec=krb5 on RHEL and CentOS
Date: Sun, 21 Jan 2007 17:11:29 -0500
Message-ID: <a3b675320701211411r45d010f8jd7132deedcf68804@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H8kuQ-0006HF-Lx
	for nfs@lists.sourceforge.net; Sun, 21 Jan 2007 14:11:30 -0800
Received: from ug-out-1314.google.com ([66.249.92.175])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H8kuR-00055Q-7I
	for nfs@lists.sourceforge.net; Sun, 21 Jan 2007 14:11:32 -0800
Received: by ug-out-1314.google.com with SMTP id z38so872308ugc
	for <nfs@lists.sourceforge.net>; Sun, 21 Jan 2007 14:11:29 -0800 (PST)
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

I couldn't get sec=krb5 to work on clients running RHEL4 (and CentOS),
so I built a slightly newer version of nfs-utils. (nfs-utils-1.0.7-13)

I can now get the exports to mount, but I'm seeing some very strange behavior.

A mkdir return a file exists error, but the directory is created.
Redirecting std out to a file returns an ioerror, and the file is
created but empty.
Vim creates swap files, they fail so it doesn't use them, but reports
them as existing.

I can chmod, chown existing files as expected.

The server is a netapp filer. Other distros (Ubuntu, Fedora) work as
expected. FC4 with the above version of nfs-utils works filne.

thanks
-jim

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: wolfgang@noten5.maas-noten.de
Subject: access failure
Date: 26 Feb 2007 13:51:43 -0000
Message-ID: <wolfgang-1070226145143.A012177@noten5.maas-noten.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLgHY-00022U-CT
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 05:52:48 -0800
Received: from maas-noten.de ([213.239.193.103])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HLgHY-00078a-0Z
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 05:52:50 -0800
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



I occasionally get access failures on an nfs volume
The files are mode 666, owned by a user who has no account on the nfs machine.
The volume is exported rw, no_root_squash and mounted rw by clients

When the error occurs, the file has been truncated but cannot be written

Changing ownership of the file to someone else helps

The server is running kernel nfs on suse 10.1

Wolfgang Hamann


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

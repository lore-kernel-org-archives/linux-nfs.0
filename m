From: Tollef Fog Heen <tfheen@err.no>
Subject: Problems building nfs with 2.6.19 kernel headers
Date: Wed, 15 Nov 2006 18:43:20 -0800
Message-ID: <455BD048.5020009@err.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkXE9-00043A-7u
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 18:43:45 -0800
Received: from doom.no ([194.24.252.214] helo=sigma.hardware.no)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GkXE9-0008CF-5d
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 18:43:46 -0800
To: nfs@lists.sf.net
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

Hi,

I have trouble building nfs-utils with 2.6.19 kernel headers due to the 
removal of UTS_RELEASE from linux/version.h.  This causes getkversion to 
fail to build.

What is the purpose of getkversion and is there any reason not to remove it?

(Please Cc me on replies, I'm not on the list)

- tfheen


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

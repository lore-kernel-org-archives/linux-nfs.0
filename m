From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 0 of 6 - Intro
Date: Thu, 04 Sep 2003 16:25:55 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19unZ5-0004Us-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19unZJ-00027F-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 23:26:09 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19unZI-0002HV-Q1
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 23:26:08 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <marcelo.tosatti@cyclades.com.br>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Thu, 4 Sep 2003 16:25:55 +1000
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
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

Hi,
here are 6 patches for knfsd in 2.4.22-pre.
- A couple of little locking fixed for obscure situations.
- fix a bug related to tcp sockets being closed
- Make sure udp replies are sent from the IP address that the request was sent to.
- change NFSEXP_CROSSMNT to NFSEXP_NOHIDE in line with the real meaning of the flag
- Fix a lockd bug.

Most of these are already in 2.6

NeilBrown



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

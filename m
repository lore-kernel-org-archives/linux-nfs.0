From: Bernd Schubert <bernd-schubert@web.de>
Subject: fsid syntax
Date: Wed, 7 Aug 2002 17:11:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208071711.00712.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cSSn-0001eZ-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 08:11:06 -0700
Received: from ix.urz.uni-heidelberg.de (mail.urz.uni-heidelberg.de [129.206.119.234])
	by relay2.uni-heidelberg.de (8.12.4/8.12.4) with ESMTP id g77FB12T028801
	for <nfs@lists.sourceforge.net>; Wed, 7 Aug 2002 17:11:01 +0200 (MET DST)
Received: from euklid (bernd@euklid.pci.uni-heidelberg.de [129.206.21.104])
	by ix.urz.uni-heidelberg.de (8.8.8/8.8.8) with ESMTP id RAA36932
	for <nfs@lists.sourceforge.net>; Wed, 7 Aug 2002 17:11:01 +0200
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi,

probably on Friday I need to make use of setting the fsid in the /etc/exports.

Since I can't find the syntax in the exports manpage (manpage was last time 
changed on Januar, while the fsid-feature seems to be become added to cvs on 
February).

So I'd like to know the exact sytanx, is for example:

/testdir	testnode(fsid=/dev/sdb)

correct to make 'testnode' believing that sdb is exported?


Thanks in advance,

Bernd

-- 
Bernd Schubert
Physikalisch Chemisches Institut
Abt. Theoretische Chemie
INF 229, 69120 Heidelberg
Tel.: 06221/54-5210
e-mail: 	bernd (dot) schubert (at) pci (dot) uni-heidelberg (dot) de 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

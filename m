From: Christopher Penney <cpenney@ford.com>
Subject: Solaris 8 Server / RedHat 7.2 Clients
Date: Fri, 19 Jul 2002 22:14:45 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207200214.g6K2EkI32355@dymwsm10.mailwatch.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dymwsm05.mailwatch.com ([204.253.83.41])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Vjlm-0004q5-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Jul 2002 19:14:54 -0700
Received: from mwsc0201.mw4.mailwatch.com (mwsc0201.mw4.mailwatch.com [204.253.83.131])
	by dymwsm05.mailwatch.com (8.11.0/8.11.0) with ESMTP id g6K2EkG06404
	for <nfs@lists.sourceforge.net>; Fri, 19 Jul 2002 22:14:46 -0400
Received: from eccmfw6.ford.com (mailfw6.ford.com [136.1.1.30])
	by dymwsm10.mailwatch.com (8.11.0/8.11.0) with ESMTP id g6K2EkI32355
	for <nfs@lists.sourceforge.net>; Fri, 19 Jul 2002 22:14:46 -0400
Received: by mailfw6.ford.com id WAA21974
  (InterLock SMTP Gateway 4.2 for nfs@lists.sourceforge.net);
  Fri, 19 Jul 2002 22:13:35 -0400 (EDT)
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


Is there a preferred setup when using a Solaris 8 NFS server with only
RedHAt 7.2 clients?  The server is exporting a 1TB file system to several
Compaq Alpha's running RedHat 7.2 (2.4.9-32smp) that are sitting behind a
NAT router.

Right now, I'm automounting the file system's user dirs with the following
options:

   rw,intr,hard,bg,wsize=8192,rsize=8192,nfsvers=3,udp

Should I be using a 32k w/rzise with a Solaris 8 server?  Anything else
I'm missing?  Anything I shoudl take into consideration with a NAT router
in between?  Everything seems to be working well, but I'm looking for any
improvements I can make.

Oh, it's all gigabit ethernet except for each clients connection to the
switch, which is 100mbit.

   Chris




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

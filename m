From: Bernd Schubert <bernd-schubert@web.de>
Subject: export only to special mac addresses
Date: Thu, 21 Mar 2002 19:07:04 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200203211807.g2LI74M02426@fubini.pci.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16o6xy-0001P2-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Mar 2002 10:07:10 -0800
Received: from fubini.pci.uni-heidelberg.de (fubini.pci.uni-heidelberg.de [129.206.21.240])
	by relay.uni-heidelberg.de (8.12.1/8.12.1) with ESMTP id g2LI75mB016149
	for <nfs@lists.sourceforge.net>; Thu, 21 Mar 2002 19:07:05 +0100 (MET)
Received: from there (euklid.pci.uni-heidelberg.de [129.206.21.104])
	by fubini.pci.uni-heidelberg.de (8.11.0/8.11.0/SuSE Linux 8.11.0-0.4) with SMTP id g2LI74M02426
	for <nfs@lists.sourceforge.net>; Thu, 21 Mar 2002 19:07:05 +0100
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

Hi all,

we are exporting a root filesystem to several clients. Since the clients are 
allowed  to write to the filesystem, we have a bad feeling about security 
(though we have a firewall).

To slightly increase security we would like to allow only clients with 
special MAC addresses to mount this fs.
So I'd like to know if there is already support for this.

Thanks in advance,

Bernd



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Nicolas CROS <Nicolas.Cros@cls.fr>
Subject: Solaris Server/Linux Clients NFS Performance Problem
Date: Thu, 28 Mar 2002 17:47:50 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CA34936.ED451E6E@cls.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Christophe Kersuzan <ckersuzan@cls.fr>,
   Lionel Cazaux <lionel.cazaux@cadrus.fr>
Received: from priam.cls.fr ([62.161.32.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16qd4D-0000FK-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Mar 2002 08:48:01 -0800
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

Hello,

We have severe performances problems on our configuration :
	. a NFS server running on Solaris2.8=20
	. several NFS clients running Linux (Redhat, Mandrake) or
	Solaris 2.7

For testing purpose, i copied a 268MB from /dev/zero to
the NFS mounted FS. Here's the results :

NFS Client	NFS Server	Time
linux		linux		36s
linux		solaris		208s
solaris		solaris		26s
solaris		linux		47s

We do not experiment problems when file transfer are done without
NFS (rcp for example), neither when reading files.

I tried to play with mount options without success (-o -w=3D , -o tcp)

Any ideas welcome !!

--
Nicolas.Cros@cls.fr             CLS
Administrateur Syst=E8me          8-10 rue Herm=E8s
tel 05.61.39.48.81              Parc Technologique du Canal
fax 05.61.39.48.40              31526 Ramonville St Agne cedex, France

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

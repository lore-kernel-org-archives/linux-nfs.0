From: Gavin Woodhatch <gavin.woodhatch@netzone.ch>
Subject: NFS Performance
Date: Thu, 18 Apr 2002 21:19:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <21851575821.20020418211902@netzone.ch>
Reply-To: Gavin Woodhatch <gavin.woodhatch@netzone.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail1.hostpark.net ([212.243.197.31])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16yHR1-0003Fy-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Apr 2002 12:19:12 -0700
Received: from localhost (localhost [127.0.0.1])
	by mail1.hostpark.net (Postfix) with ESMTP id F25BF7BC86
	for <nfs@lists.sourceforge.net>; Thu, 18 Apr 2002 21:25:41 +0200 (CEST)
Received: from jamie (unknown [195.144.47.58])
	by mail1.hostpark.net (Postfix) with ESMTP id CF6097BB03
	for <nfs@lists.sourceforge.net>; Thu, 18 Apr 2002 21:25:40 +0200 (CEST)
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

Hi All

I am new to the list, but have been reading the Archives.

I need to Backup about 50 GB of Data. The Data is on a NFS Mounted
Partition. A local Backup is not possible.

The Data is mainly small files (HTML Pages, Pictures etc.) But there
are also some bigger files.

The Network thruput vary's from about 1-2 MB/s to 9 -10 MB/s. It is a
100 Mbit Network (Switched), the NFS Server is connected with a 1
Gbit Link.

I am Running a 2.4.17 Kernel with Trond's 2.4.17 NFS-all Patch.


I have tried the following mount options :

-o vers=3,async,hard,intr,nolock

Varied with differnt wsize and rsize (from 4096 to 32768, and also not
specified) , also tried with the option tcp.

The Max thruput changes a bit depending on the options but the
avg. does not change a great deal. (about 80 - 120 MB/min)

The NFS Server is a Auspex NS2000.

Anyone got an Idea how to get Linux to read the small files faster, or
howto just generaly make things faster (Read) ?

Any Ideas would be most welcome.

PS Sorry for the bad spelling, my english is rather rusty...


--

Freundliche Grüsse (Kind Regards)


NetZone Ltd.
Gavin Woodhatch

******************************************************************
*  NetZone AG                                        Webhosting  *
*  http://www.netzone.ch                        info@netzone.ch  *
*  Alpenweg 12                            Tel. +41 62 724 08 08  *
*  CH-5035 Unterentfelden                 Fax. +41 62 724 08 06  *
******************************************************************


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

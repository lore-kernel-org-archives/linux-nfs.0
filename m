From: Rex Dieter <rdieter@math.unl.edu>
Subject: statd: server localhost not responding, timed out
Date: Thu, 2 Oct 2003 11:45:37 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200310021145.37822.rdieter@math.unl.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A56aj-00085U-00
	for <nfs@lists.sourceforge.net>; Thu, 02 Oct 2003 09:46:13 -0700
Received: from mathstat.unl.edu ([129.93.48.14])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A56ah-0006UR-LW
	for nfs@lists.sourceforge.net; Thu, 02 Oct 2003 09:46:11 -0700
Received: from stat02.unl.edu (stat02.unl.edu [129.93.48.150])
	(authenticated bits=0)
	by mathstat.unl.edu (8.12.8/8.12.8) with ESMTP id h92Gjcvf020726
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NO)
	for <nfs@lists.sourceforge.net>; Thu, 2 Oct 2003 11:45:39 -0500
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

We have a venerable (and usually) rock-solid NFS server running redhat 
linux 6.2, kernel-2.2.24-6.2.3, nfs-utils-1.0.1 and we're seeing 
periodically (2-3 times a week), where the server seems to go off into 
la-la land for 5-10 minutes at a time.  During which, it doesn't respond 
to any *new* network requests (nfs, sendmail, etc), though existing nfs 
mounts seem to continue to work.

During this 5-10 minute period of la-la-ness, the system log records 
1-several entries of the form: (hostnames, ip's changed to protect the 
innocent):
Oct ... mathstat kernel: statd: server localhost not responding, timed out
Oct ... server kernel: lockd: cannot monitor 192.168.1.77
Oct ... server kernel: statd: server localhost not responding, timed out
Oct ... server kernel: lockd: cannot unmonitor 192.168.1.49
Oct ... server kernel: statd: server localhost not responding, timed out
Oct ... server kernel: lockd: cannot monitor 192.168.1.90
Oct ... server kernel: statd: server localhost not responding, timed out
Oct ... server kernel: lockd: cannot monitor 192.168.1.77
Oct ... server kernel: statd: server localhost not responding, timed out
Oct ... server kernel: lockd: cannot monitor 192.168.1.90
Oct ... server kernel: statd: server localhost not responding, timed out
Oct ... server kernel: lockd: cannot monitor 192.168.1.77
Oct ... server kernel: statd: server localhost not responding,timed out
Oct ... server kernel: lockd: cannot monitor 192.168.1.90
Oct ... server rpc.statd[450]: Received erroneous SM_UNMON request from 
server for 192.168.1.49

Any ideas?  Suggestions?

-- 
Rex A. Dieter			rdieter@math.unl.edu 
Computer System Administrator 	http://www.math.unl.edu/~rdieter/
Department of Mathematics  	University of Nebraska Lincoln

"The best lack all conviction, while the worst are full of passionate 
intensity..."
-- W. B. Yeats



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

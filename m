From: "Jarod Beekman" <JBeekman@apu.edu>
Subject: Tracking rpc errors 'svc: unknown version (0)'
Date: Wed, 17 Jul 2002 07:41:02 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <78B78720E680564CB7302950FA6CCF17D302EB@james.fs.apu.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from james.apu.edu ([199.184.236.201] helo=james.fs.apu.edu)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17UpzG-0008NY-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Jul 2002 07:41:06 -0700
To: <nfs@lists.sourceforge.net>
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

I upgraded our nfs server from 2.4.9-34 Redhat 7.2 to 2.4.18-5 Redhat
7.3 and I am now seeing 'svc: unknown version (0)' errors.  Poking
around on the list and the net tells me that this is a reflection of an
unrecognized rpc request.  Is this correct, and if so is there a way to
track down the source and nature of the request?  Thanks for your help.

     Jarod Beekman
  System Administrator
Azusa Pacific University=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

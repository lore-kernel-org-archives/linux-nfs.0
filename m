From: Steven Timm <timm@fnal.gov>
Subject: nfs: task 51504 can't get a request slot
Date: Wed, 15 May 2002 16:21:51 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.31.0205151619170.27374-100000@snowball.fnal.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from snowball.fnal.gov ([131.225.81.94])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1786DY-0003Yo-00
	for <nfs@lists.sourceforge.net>; Wed, 15 May 2002 14:21:52 -0700
Received: from localhost (timm@localhost)
	by snowball.fnal.gov (8.9.3/8.9.3) with ESMTP id QAA27536
	for <nfs@lists.sourceforge.net>; Wed, 15 May 2002 16:21:52 -0500
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


REcently I have seen a number of nodes running Redhat 7.1 plus 2.4.9-31
kernel give the above message a number of times.  Any process which
is trying to access nfs at the moment hangs and can't be killed
except by shutting down the network altogether, plus the load
spikes by one for each one of these processes.

My nfs clients are using nfs v2.

Any idea what causes this and if there is any workaround short of a kernel
upgrade?

Steve Timm

------------------------------------------------------------------
Steven C. Timm (630) 840-8525  timm@fnal.gov  http://home.fnal.gov/~timm/
Fermilab Computing Division/Operating Systems Support
Scientific Computing Support Group--Computing Farms Operations


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

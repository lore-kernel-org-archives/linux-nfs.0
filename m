From: David Dougall <davidd@et.byu.edu>
Subject: exportfs error
Date: Mon, 16 Sep 2002 09:22:02 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0209160911220.5894-100000@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from postal2.et.byu.edu ([128.187.122.132])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qxhM-0002zJ-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Sep 2002 08:22:04 -0700
Received: (from root@localhost)
	by postal2.et.byu.edu (8.9.3 (PHNE_25184)/8.9.3) id JAA01386
	for nfs@lists.sourceforge.net; Mon, 16 Sep 2002 09:22:12 -0600 (MDT)
Received: from lewis (lewis.et.byu.edu [128.187.112.50])
	by postal2.et.byu.edu (8.9.3 (PHNE_25184)/8.9.3) with ESMTP id JAA01298
	for <nfs@lists.sourceforge.net>; Mon, 16 Sep 2002 09:22:11 -0600 (MDT)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I have an NFS failover cluster.  The /var/lib/nfs directory is not shared,
but it is synchronized at regular intervals.  When one server fails, the
other server is supposed to pick up and continue the service.  Most of the
time it works, but sometimes while the 2nd server is running exportfs, I
get a list of:
hostname:/grp2: Invalid argument
The script detects an error and fails to start the nfs service correctly.
Usually I am able to rerun the script by hand and it works just fine.  Is
there something obvious here that I should look for before I delve into
the code.  I am running 2.4.19-rc3 with SGI's XFS patches.  I am also
running what I think is the most recent nfs-utils; version 1.0.1
Thanks in advance for any help.
--David Dougall


______________________________________
Inflex Virus Scanner - installed on mailserver for domain @et.byu.edu
Queries to: postmaster@et.byu.edu


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

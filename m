From: Yu Chen <chen@hhmi.umbc.edu>
Subject: Darwin nfs mounting question?
Date: Tue, 23 Jul 2002 10:03:56 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SGI.4.44.0207230957070.14795-100000@cobalt.hhmi.umbc.edu>
References: <E17WiTt-0007SF-00@usw-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from zinc.hhmi.umbc.edu ([130.85.139.230])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17X0Gd-00068X-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 07:03:59 -0700
Received: from cobalt.hhmi.umbc.edu (cobalt.hhmi.umbc.edu [130.85.139.161])
	by zinc.hhmi.umbc.edu (8.9.3/8.9.3) with ESMTP id KAA116012
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 10:03:57 -0400 (EDT)
Received: from localhost (chen@localhost)
	by cobalt.hhmi.umbc.edu (8.9.3/8.9.3) with ESMTP id KAA14828
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 10:03:57 -0400 (EDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <E17WiTt-0007SF-00@usw-sf-list2.sourceforge.net>
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

Dear all;

I am tring to mount disks over nfs on Darwin, but failed. Any helps would
be highly appreciated. Here are my information:

I was able to nfs mount the disk on Darwin when the nfs disk was in XFS
file system. Then we formated the disk as ReiserFs file system,and changed
nothing else. The automount seems work fine on Darwin, it doesn't give any
error message when started, but when I try to 'cd' to the directory, it
gives me error message saying:" Operation not permitted".

Anyone has any suggestions? Thanks in advance for the helps!





===========================================
Yu Chen
Howard Hughes Medical Institute
University of Maryland Baltimore County
1000 Hilltop Circle
Baltimore, MD 21250

phone: (410)455-6347
fax: (410)455-1174
email: chen@hhmi.umbc.edu
===========================================




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: David Dougall <davidd@et.byu.edu>
Subject: problem with rquotad
Date: Wed, 3 Sep 2003 11:34:32 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.51.0309031058160.28747@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ubXG-0006B3-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 10:35:14 -0700
Received: from postal3.et.byu.edu ([128.187.122.133])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19ubXF-0007Br-OZ
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 10:35:13 -0700
Received: from mail by postal3.et.byu.edu with local (Exim 4.20)
	id 19ubWc-0006cv-IS
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 11:34:34 -0600
Received: from lewis.et.byu.edu ([128.187.112.50])
	by postal3.et.byu.edu with esmtp (Exim 4.20)
	id 19ubWb-0006bs-Vt
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 11:34:34 -0600
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

Recently replaced the rest of our HPUX nfs servers with linux.
Since this move, we cannot view any of our quotas from these servers
through rquotad.  If we run quota -v on the local nfs server, it will
repond with the correct information, but if we do a quota -v from an nfs
client, it responds with 0 usage and 0 quota no matter what.
We have 1 group of linux nfs servers that has been working just fine for
over a year now:
2.4.19-rc3-xfs
nfs-utils-1.0.1
PIII single processor 1Gig memory

The broken group of machines is:
2.4.21-xfs
nfs-utils-1.0.4(with free patch)
P4 single processor 2Gig memory

All of the filesystems are xfs with quotas enabled.  I did a tcpdump from
the client and he is sending the same requests to the servers, and getting
responses from all of the servers.  The new group of servers is just
returning no quota information.
What can I do to narrow this down more?  I didn't think any rquotad
changed between 1.0.1 and 1.0.4.  I tried reverting one of the new servers
to 1.0.1, but it didn't seem to make any difference.
Is there some way to get debugging information out of rquotad on the
server?
All of these machines use an almost identical image that was once upon a
time based on Redhat 7.1.
Any help would be appreciated.
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

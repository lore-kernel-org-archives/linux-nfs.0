From: Donavan Pantke <avatar@dcr.net>
Subject: Strange file read problem 2.4.18 SuSE
Date: Thu, 8 May 2003 21:25:20 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200305082125.20851.avatar@dcr.net>
Reply-To: avatar@dcr.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 216-7-67-178.ip.win.net ([216.7.67.178] helo=richard.dpapt.spellboundnet.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Dwdc-0002L4-00
	for <nfs@lists.sourceforge.net>; Thu, 08 May 2003 18:25:28 -0700
Received: from avatar.dpapt.spellboundnet.com (unknown [10.0.4.25])
	by richard.dpapt.spellboundnet.com (Postfix) with ESMTP id 46F5D185D3
	for <nfs@lists.sourceforge.net>; Thu,  8 May 2003 21:25:21 -0400 (EDT)
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

	ALright guys, we've been troubleshooting this problem at the office, and now 
I need a little developer help with this. lol First, the setup is 2 SuSE SLES 
7 machines running SuSE's patched 2.4.18 kernel. We have an app which listens 
on a socket and accepts file through a proprietary protocol. It writes the 
file to the NFS server, then it calls an import thread which then imports the 
file into an Oracle database. The app is written purely in java, so the 
improt is a seperate class that is instantiated and handed it's own thread. 
Now, this works fine the vast majority of the time, but occasionally, when 
dealing with a 10+M file, the import will barf reading the file (it's a 
line-by-line read, so it's not like a copy, which block-by-blocks as fast as 
possible), with the error message "No such file or directory". ANyone can ls 
and see that indeed, the file does exist, and the next time the import runs 
(after a new file comes down, the importer will process all pending files 
before grabbing the new one), it'll import the 10M file just fine (problem 
being that part of the file was already imported, so data can get 
duplicated).
	I was able to replicate an error similar to this one under different 
conditions: when the cluster that advertises teh NFS export to clients mvoes 
from one node to another, then reads can fail with the same error message, at 
which point a file close and open solves things. Howver, in this case the 
cluster isn't moving, so I'm kinda at a loss. 

	SO, questions are:
	What kinds of situations can lead to this error being given by the client, 
and:
	what can I do to troubleshoot?

	Thanks!
	Donavan Pantke


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

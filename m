From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: NFS Tuning
Date: 15 May 2003 06:24:45 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1052997886.12158.10.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GGmU-0002O0-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 04:20:15 -0700
Received: from mosix.vss.fsi.com (mosix [198.51.27.89])
	by esds.vss.fsi.com (8.9.1a/8.9.1) with ESMTP id GAA27018
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 06:20:07 -0500 (CDT)
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

For NFS Version 3, is there a formula to help administrators tune NFSD
to their environment?

I'm looking at thread count, and obviously see the advantages that
adding threads to a server that is experiencing large number of thread
overutilization, but I am wondering if there is a way to best calculate
the threads needed.

Such as:

CPU Speed:

RAM: 

Total Bandwidth of Serving Network Interfaces, and How many network
interfaces served:

Number of Clients: (Would OS of clients affect - are some 'more
efficient consumers than others?)

Equals: How many threads this machine can handle or should be using.



Also, another tuning item i found was for Memory limits for the input
queue.  It recommends 256K for a standard install, as opposed to the
default 64K.

Standard setup has 8 threads, so 256K gives each thread 32K input queue.
For 16 threads, does the calculation still hold true? (512K input queue=
32K/thread)  What are the signs that can allude to input queue problems?

I'm just trying to tune my servers in a less than trial and error
method.


Thanks for your help,




-- 
Matt Schillinger
mschilli@vss.fsi.com




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

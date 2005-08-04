From: "Weathers, Norman R." <Norman.R.Weathers@conocophillips.com>
Subject: rpciod Problems
Date: Thu, 4 Aug 2005 15:15:47 -0500
Message-ID: <D821697F08061F4FBB069FA1AAAA92370C45B1@hoexmb7.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E0m88-0002FP-Qu
	for nfs@lists.sourceforge.net; Thu, 04 Aug 2005 13:15:52 -0700
Received: from mailman1.ppco.com ([138.32.33.10])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1E0m87-0006tT-4t
	for nfs@lists.sourceforge.net; Thu, 04 Aug 2005 13:15:52 -0700
Received: from bvlextrd01.conoco.net (trend1.ppco.com [138.32.33.139])
	by mailman1.ppco.com (8.12.8/8.12.8) with ESMTP id j74KFnRJ027510
	for <nfs@lists.sourceforge.net>; Thu, 4 Aug 2005 15:15:49 -0500
Received: from bvlexbh2.conoco.net (bvlexbh2.conoco.net [138.32.45.42])
	by mail1.ppco.com (8.11.6+Sun/8.11.6) with ESMTP id j74KFmO11104
	for <nfs@lists.sourceforge.net>; Thu, 4 Aug 2005 15:15:48 -0500 (CDT)
To: <nfs@lists.sourceforge.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

I appear to be having an issue with the NFS client in the 2.6.12.1
kernel.  Here are the vital statistics:

Fedora Core 3 clients, 2.6.12.1 kernels.  Boxes are Opterons (2200 MHz)
with 4G of RAM.

Servers:  Various, FC3 i386 and Opterons
			 FC2 i386
			 RedHat 7.3 i386

>From our testing, it appears that whenever our clients go into long
writes (something around 2G or more), the clients rpciod/0 thread
appears to start taking a lot of CPU time, sometimes it takes 100 % of a
CPU for long periods of time.  Eventually, you will notice the load to
start and climb on the client that the rpciod thread is running 100 %.
Then, as more services are needing to write over NFS, they too start
using more CPU time.  In the end, the nodes will become unresponsive to
NFS.  They become so slow that logins are no longer possible over the
network.  We have the client nodes on serial consoles, so we have been
able to get the console open and run SysRq T and see that a lot of
processes are in IO wait.  This was not an issue, as far as we could
tell, in the 2.6.11.7 kernel (although there were other problems with
this kernel that would not allow us to use it).

I noticed in a thread that someone suggested lowering some vm settings,
and we have done this, and as of yet, have not seen the larger spikes
from the past.  The question is, "Is this the preferred method of fixing
this issue?"

Other bit of information:  We are using Trond's NFS_ALL patches.

Any information anyone can give would be most useful.

Also, we have several nodes for testing if patches are needed.

Thanks in advance.

Norman Weathers


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

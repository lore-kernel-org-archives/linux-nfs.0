From: Nick Couchman <nick-lists@seakr.com>
Subject: Root Over NFS Memory Problem
Date: Wed, 03 Mar 2004 10:58:00 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078336680.31825.19.camel@nick0.seakr.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ayaig-0008A8-0d
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 10:03:46 -0800
Received: from gw2.seakr.com ([209.144.181.2] helo=mail-gw.seakr.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AyadF-0004dp-Kp
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 09:58:09 -0800
Received: from scan-gw.seakr.com (seakr5.seakr.com [192.168.100.10])
	by mail-gw.seakr.com (8.12.10/8.12.10) with ESMTP id i23Hrg6a002964
	for <nfs@lists.sourceforge.net>; Wed, 3 Mar 2004 10:53:42 -0700
Received: from nick0.seakr.com (nick0 [192.168.10.70])
	by seakr5.seakr.com (8.10.2/8.10.2) with ESMTP id i23Hw1Z17198
	for <nfs@lists.sourceforge.net>; Wed, 3 Mar 2004 10:58:01 -0700 (MST)
To: nfs@lists.sourceforge.net
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

I'm trying to run a few clients using NFS for the root filesystem.  I'm
having a problem with what appears to be a memory "leak" (I'm not sure
it's actually a leak, but for all intents and purposes, it is).  What
happens is that I lose 8k of free memory every time I run a command. 
For example, if I repeatedly run the "free" command, the free memory
will drop 8k each time I run it.  If I instead run "free -s 1" (telling
free to update at 1 second intervals), it drops a couple of times and
then levels out.  The problem is bad enough that one of the clients ran
out of memory (swap - on a local hard drive - and physical RAM) the
other night and "kernel panicked".  The clients are running kernel
version 2.4.22 with the OpenMosix patch (2.4.22 seems to be the latest
"stable" OpenMosix version).  Has anyone run across this problem
before?  Any ideas what I can do to fix it?  Is it a known NFS bug in
2.4.22 that is fixed in later versions?  (I'm about to try another
version of the kernel which might give me an answer to that, but I
thought I'd ask).

Thanks in advance!
-- 
Nick Couchman <nick-lists@seakr.com>



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

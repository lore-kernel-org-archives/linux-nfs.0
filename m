From: Georg Ritter <newsgr.2007@gamebox.net>
Subject: sco 5(server) linux(client, FC4) cp stalls after a few ten KBs
Date: Wed, 13 Dec 2006 02:44:06 +0100
Message-ID: <457F5AE6.90900@gamebox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuIGd-0007R0-K1
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 16:46:39 -0800
Received: from viefep16-int.chello.at ([213.46.255.18]
	helo=viefep14-int.chello.at)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GuIGd-00036R-JU
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 16:46:41 -0800
Received: from [213.47.225.118] by viefep14-int.chello.at
	(InterMail vM.6.01.05.04 201-2131-123-105-20051025) with ESMTP
	id <20061213004618.HTHZ21691.viefep14-int.chello.at@[213.47.225.118]>
	for <nfs@lists.sourceforge.net>; Wed, 13 Dec 2006 01:46:18 +0100
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Dear NFS gurus :-),

Problem:
FC4 box as client to a SCO 5 server stops copying after a few 10 KBs, worked on 
same hardware with RH9 as client, and currently still works for a mdk10 client.

I would be grateful for a hint or better a way to fix it, as I have no idea of 
what else could be wrong and where/how to investigate it further.

Longer description:
I ran into the following problem, after upgrading from RH9 to FC4 (and also 
another FC6 box has the same "behaviour") and completely ran out of ideas.

Setup:
FC4/FC6 boxes as clients connecting to an SCO nfs server, small LAN, all class A 
IPs.

Client can mount the exports from the SCO server, but after a few 10KB of data 
the speed drops near or to zero and it gets stuck and still seems to copy a few 
bytes every 30 secs or minute.

Findings so far:
mdk10 laptop as a client can mount the SCO dirs and copies full speed.

It used to work with the exact same hardware but RH9 instead of FC4/FC6.

Looks like a buffer gets filled and then it gets stuck.

nfsd on the SCO don't die away.

No errors on SCO portmap (-v -d) (additionally it worked before, and serves the 
mdk10 box, without touching the settings on the SCO server)

setting the debugging output on FC4 to 32565 with echo into the according 
/proc/... vars reveals no obvious error message.

No errors with nfsstat neither on SCO nor FC4.

Network is at good health.

It works the other way round (SCO as client mounting from FC4 box)

Disabled (on FC4) firewall and selinux. No such things on the SCO box.

Seem to be ok in principal because it mounts and copies fine up to the stop 
after a few ten KBs.

Tried different kernels on the FC4 box (all plain vanilla kernels offered via 
official update path)

Tried many different options on the mount command: vers=2, nolock different 
package sizes, forcing tcp etc.: no effect



Thanks,

         Georg

P.S. More details from the FC4 (client) box available (logfiles, etc).

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

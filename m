From: Franziska Heinze <Franziska.Heinze@rwth-aachen.de>
Subject: NFS basics ??
Date: Tue, 20 Jan 2004 17:12:54 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <dde25de25c.de25cdde25@post.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AiybZ-0007aK-0P
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 08:19:53 -0800
Received: from ms-2.rz.rwth-aachen.de ([134.130.3.131] helo=ms-dienst.rz.rwth-aachen.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AiybX-0002qg-2O
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 08:19:51 -0800
Received: from r220-1 (r220-1.rz.RWTH-Aachen.DE [134.130.3.31])
 by ms-dienst.rz.rwth-aachen.de
 (iPlanet Messaging Server 5.2 HotFix 1.12 (built Feb 13 2003))
 with ESMTP id <0HRS00GLJQDJTS@ms-dienst.rz.rwth-aachen.de> for
 nfs@lists.sourceforge.net; Tue, 20 Jan 2004 17:12:55 +0100 (MET)
Received: from post.rwth-aachen.de (ms-2.rz.RWTH-Aachen.DE [134.130.3.131])
	by relay.rwth-aachen.de (8.12.10/8.12.7-1) with ESMTP id i0KGCsJC001582	for
 <nfs@lists.sourceforge.net>; Tue, 20 Jan 2004 17:12:54 +0100 (MET)
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

Hello,

I'm quite new to Linux in general, so may be one or the other question may sound quite simple to you. Nevertheless:

My situation:
I have a Workstation with static IP runnning RedHat 9.0. This is the NFS Server.
Secondly I have a singele-chip PC with a flash ROM running RedBoot which then loads the Linux Busybox system if not interrupted. It also has ethernet connection and a static IP. This is the client
system.

I'd like to have the client system booting via NFS from the server system, so that I can develop software and perhaps alter the operating system for the single-chip PC on the server system and thus reducing time for development.

In principle I thought I have to do as following:
- setting up the NFs server under RedHat
- changing the bootscript under redboot to boot/ execute the busybox from the server like:
exec -c"root=/dev/nfs rw nfsroot=12.345.67.89:/path/on/server/to/nfs_root ip=12.345.67.88::12.345.67.1:255.255.255.0:embed-o-matic:eth0:off console=ttyS1 init=/bin/init"

As you will know that's not working.
What have I to do instead, step by step ?
I'm thankful for every hint !

Cheers,
Franziska.





-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

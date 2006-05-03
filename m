From: Erik Walthinsen <omega@temple-baptist.com>
Subject: Breaking locks on a lame server?
Date: Tue, 02 May 2006 20:17:04 -0700
Message-ID: <445820B0.8080107@temple-baptist.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fb7rT-0002bk-Sh
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 20:17:11 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fb7rT-0003t5-Hu
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 20:17:11 -0700
Received: from [216.99.212.251] (helo=mail.omegacs.net)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fb7rR-00012g-OK
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 20:17:11 -0700
Received: from [10.1.1.3] (omicron [10.1.1.3])
	by mail.omegacs.net (8.11.6/8.11.0) with ESMTP id k433opq31597
	for <nfs@lists.sourceforge.net>; Tue, 2 May 2006 20:50:54 -0700
To: nfs@lists.sourceforge.net
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

We've got a configuration with a NAS machine (3ware SATA RAID) running a 
2.4.26 kernel is in use by a number of client machines, each running 
multiple instances of user-mode-linux.  Most all "block devices" presented 
to the UML instances are located on the NAS, exported via NFS.  The clients 
are currently a mix of 2.4.26 and 2.6.15.6.

The problem is, whenever there's any kind of abnormal shutdown of either a 
UML instance or the machine that's running it, a NFS lock is left in place. 
  This means that UML refuses to start up again using those files, unless I 
patch the UML kernel to avoid F_SETLK, which is of course very unsafe (two 
UMLs touching the same file means EDEADFILE).

I've seen other suggestions for breaking locks that involve restarting statd 
on the clients, etc., but the problem is this: these locks are persistent 
across reboots of the clients.  IIRC they're also persistent *between* 
clients, so I can't start a UML instance on an alternate machine either.

We're planning an upgrade of the NAS box to 2.6 as soon as we can, but that 
means a system-wide shutdown of all our customer's UML instances, which 
isn't something we do lightly.

1) am I to expect 2.6's NFS server implementation to somehow solve this?
2) if not, and in the meantime, are there any means by which I can inspect 
(lslk does nothing) and hopefully kill these locks?

(I'm not on the list, already on too many, so please make sure to send to: 
or cc: me)

Thankx,
       Omega
       aka Erik Walthinsen
       omega@vcolo.com


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

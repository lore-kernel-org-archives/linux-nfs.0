From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: ENOLCK - /etc/init.d/nfslock
Date: Tue, 2 Mar 2004 10:22:59 -0700 (MST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0403021022440.15713-100000@fattire.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyDgZ-0006gz-UM
	for nfs@lists.sourceforge.net; Tue, 02 Mar 2004 09:28:03 -0800
Received: from fattire.ngdc.noaa.gov ([140.172.187.207])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AyDbk-0000Vv-Du
	for nfs@lists.sourceforge.net; Tue, 02 Mar 2004 09:23:04 -0800
Received: from localhost (ahoward@localhost)
	by fattire.ngdc.noaa.gov (8.11.6/8.11.6) with ESMTP id i22HMxQ16442
	for <nfs@lists.sourceforge.net>; Tue, 2 Mar 2004 10:22:59 -0700
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

nfs'rs-

i have an application which requires nfs locking to work which has recently
started failing with

  ENOLCK - No locks available


the rpc and lock daemons seem to be running on both client and server.  as i
said, this application had been working fine but started failing about the
same time some of our nodes were upgraded from rh7.3 to rh enterprise.

  - Red Hat Linux release 7.3 (Valhalla)
  - 2.4.20-28.7smp
  - nfs-utils-0.3.3-6.73

and

  - Red Hat Enterprise Linux WS release 3 (Taroon Update 1)
  - 2.4.21-9.ELsmp
  - nfs-utils-1.0.5-3

respectively.  


we've looked into this a bit and, for some reason, rpc.statd does not come up
on boot with rhe?  however, if we run /etc/init.d/nfslock after booting it
comes up fine.  futhermore, if we change the start level to 99 is also comes
up fine.  in all cases /var/lock/subsys/nfslock is created.  this sure seems
to be a dependancy problem?  but on what?  is this a know problem with rhe and
nfslock?

thanks for any suggestions.


-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| ADDRESS :: E/GC2 325 Broadway, Boulder, CO 80305-3328
| URL     :: http://www.ngdc.noaa.gov/stp/
| TRY     :: for l in ruby perl;do $l -e "print \"\x3a\x2d\x29\x0a\"";done 
===============================================================================




-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

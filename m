From: Daryl Herzmann <akrherz@iastate.edu>
Subject: RH7.3  IRIX 6.5.15m  NFSv3 problem
Date: Fri, 10 May 2002 23:42:34 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.42.0205102329200.19228-100000@akrherz.agron.iastate.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailhub-1.iastate.edu ([129.186.140.3])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 176OiI-0001DS-00
	for <nfs@lists.sourceforge.net>; Fri, 10 May 2002 21:42:34 -0700
Received: from mailout-1.iastate.edu (mailout-1.iastate.edu [129.186.140.1])
	by mailhub-1.iastate.edu (8.9.3/8.9.3) with SMTP id XAA20360
	for <nfs@lists.sourceforge.net>; Fri, 10 May 2002 23:42:32 -0500
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Greetings:

Environment:
  SGI Origin 2000 NFS Server IRIX 6.5.15m
  RH 7.3  2.4.18-3 NFS client 

Problem:
 I mount a Linux client via v3 to the SGI server and it appears to mount
correctly.  I can do some things on the mount and then suddenly everything
starts to bogg down.  I then receive phone calls saying that my machine is
flooding the network and all other computers in the network are dropping
connections. :)  I can usually, by either unplugging the ethernet or hard
resetting, get the machine back under my control.  Nasty!

  I can invoke this behaviour 100% of the time by launching netscape or 
mozilla.  But it has also occured doing simple file moves, etc...

If I mount with v2, I have zero problems.  Or, if I downgrade the kernel 
to 2.4.9-31, I can use v3 without noticable problems.

Idears?  I just glanced through the IRIX 6.5.16m release notes and did not 
notice anything that may help this problem.  I see that RedHat has an 
errata kernel already, so I will try that as well.

Thanks!
  Daryl



-- 
/**
 * Daryl Herzmann (akrherz@iastate.edu)
 * Program Assistant -- Iowa Environmental Mesonet
 * http://mesonet.agron.iastate.edu
 */



_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

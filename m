From: David LeBard <david.lebard@asu.edu>
Subject: Newbie at NFS
Date: Thu, 16 May 2002 11:31:52 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200205161836.g4GIa6B07347@smtp.asu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from post2.inre.asu.edu ([129.219.110.73])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178Q76-0002OS-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 11:36:32 -0700
Received: from conversion.post2.inre.asu.edu by asu.edu (PMDF V6.1 #40111)
 id <0GW700N01VO651@asu.edu> for nfs@lists.sourceforge.net; Thu,
 16 May 2002 11:36:06 -0700 (MST)
Received: from smtp.asu.edu (smtp.asu.edu [129.219.110.107])
 by asu.edu (PMDF V6.1 #40111) with ESMTP id <0GW700N30VO62P@asu.edu> for
 nfs@lists.sourceforge.net; Thu, 16 May 2002 11:36:06 -0700 (MST)
Received: from there (theochem2.la.asu.edu [129.219.83.141])
	by smtp.asu.edu (8.11.0/8.11.0/asu_smtp_relay,nullclient,tcp_wrapped)
 with SMTP id g4GIa6B07347	for <nfs@lists.sourceforge.net>; Thu,
 16 May 2002 11:36:06 -0700 (MST)
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

I am new to nfs and to this list, so please excuse my obvious ignorance.

Here is my network situation:

WAN <-> Switch <-> Internal Network w/ 5 linux 
workstations <-> master linux server (w/ 2 NICs) -> 10.0.0.x network 
w/ 3 more linux servers

so, the problem is that we need want to use nfs to connect our linux 
workstations (subnet: 255.255.255.192) to the linux servers (subnet: 
255.0.0.0) .  the only computer than can see the 10.0.0.x network is the 
master linux server.  

i have nfs running on every computer on both networks.  i have a mounted a 
drive from one of the linux servers on the 10.0.0.x network to the master 
server.  i can see all of the files on the master.  i have mounted the same 
drive from the master server (which is actually the mounted drive from linux 
server on the 10.0.0.x network) to my linux workstation, but i cannot see any 
files on there at all.

i believe what i need to do is make the master linux server into a router so 
the linux workstations can see the 10.0.0.x network on the other side of 
master.  will this even work?  does anyone have a better idea, as i am open 
to anything at this point?

Thanks,
David LeBard

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

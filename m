From: Marco.Schwarz@Freudenberg.de
Subject: Diskless client problems ...
Date: Fri, 12 Dec 2003 10:05:46 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <95AF67BA7F70D511829B0002A551737001CAAA@FAW-E01>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AUjFI-0004qq-Iv
	for nfs@lists.sourceforge.net; Fri, 12 Dec 2003 01:06:00 -0800
Received: from mailhost2.freudenberg.de ([153.95.95.71] helo=itnts96.freudenberg.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AUjFH-0000qH-VR
	for nfs@lists.sourceforge.net; Fri, 12 Dec 2003 01:06:00 -0800
Received: from fgnts03.fit.freudenberg.de (unverified) by itnts96.freudenberg.de
 (Content Technologies SMTPRS 4.3.10) with ESMTP id <T667652f19c995f5f47770@itnts96.freudenberg.de> for <nfs@lists.sourceforge.net>;
 Fri, 12 Dec 2003 10:10:11 +0100
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

Hi all,

I have a problem with a new server I am setting up right now.

When booting my diskless clients I get the following error:

Looking up port of RPC 100003/2 on 192.68.0.20
portmap: server 192.168.0.20 not responding, timed out
Root-NFS: Unable to get nfsd port number from server, using default
Looking up port of RPC 100005/2 on 192.168.0.20
portmap: server 192.168.0.20 not responding, timed out
Root-NFS: Unable to get mountd port number from server, using default
mount: server 192.168.0.20 not responding, timed out
Root-NFS: Server returned error -5 while mounting /netclients/192.168.0.24
VFS: Unable to mount root fs via NFS, trying floppy.
VFS: Insert root floppy and press ENTER

A bit more infos about my environment:

The server has 3 NICs:

eth0, 192.168.1.100	(not connected right now)
eth1, 192.168.0.20
eth2, 153.95.169.115

What is strange is that if I set up a small local network with only eth1
connected to a single switch with my clients, everything works fine !

The moment I plug everything in the company net or add eth2 to the switch,
booting is not working anymore ! (see errors above)

On the server side I can see the requests to the portmapper, but somehow the
client is not getting a response ... :

portmap[18088]: connect from 192.168.0.24 to getport(nfs)
server: about do a switch
portmap[18090]: connect from 192.168.0.24 to getport(nfs)
server: about do a switch

... and so on

I set up portmap in /etc/hosts.allow with portmap : 192.168.0. , I also
tried portmap : ALL or no entry at all, effects are the same.

Any help on this would be greatly appreciated !!!

Regards,
Marco Schwarz



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

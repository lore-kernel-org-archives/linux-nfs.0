From: Morten Sylvest Olsen <mso@medical-insight.com>
Subject: File corruption linux 2.4 nfs client to freebsd server
Date: 19 Nov 2003 10:58:48 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1069235928.1215.79.camel@krypton.medical-insight.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMP6u-0003NQ-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 01:58:56 -0800
Received: from [62.242.251.241] (helo=arsenium.medical-insight.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AMP6t-0005LI-Li
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 01:58:55 -0800
Received: from krypton.medical-insight.com (IDENT:qI9l7x2N/stC2w6EsZJkx5YVixBHd7zb@krypton.medical-insight.com [192.168.2.83])
	by arsenium.medical-insight.com (8.12.10/8.12.5) with ESMTP id hAJ9wm6b069426
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 10:58:48 +0100 (CET)
	(envelope-from mso@medical-insight.com)
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

Hi all..

I'm having a nasty problem where files seem to be corrupted by the linux
2.4 nfs client. Of course I cannot rule out the possibility that the
FreeBSD nfs server is to blame, but the problem did not appear before
upgrading to Redhat 9.

My setup: 

Server: FreeBSD 4.8-STABLE (SMP) 

Client: Redhat 9 (UP) with standard RH kernel which as far as I can see
is Linus kernel 2.4.20 plus: linux-2.4.20-irixnfs.patch,
linux-2.4.18-nfs-default-size.patch & linux-2.4.19-nfs-nosvc.patch.

Directory is mounted with options:
udp,nfsvers=3,rsize=8192,wsize=8192,nosuid, nodev, hard, intr

I couldn't make nfs over tcp work, although the bsd server should
support it.

Network is fully switched and unloaded, as is the server.

The problem seem to be related to caching, although I cannot say for
sure. It is very consistent so timing does not seem to play a big part
in this.  

copy a largish source tree (from the client)
create a tar archive from the freshly copied (from the same client)

The archiving fails at the _exact_ same file every time with the rather
strange message: 

tar: evncserver-0.4.4/programs/Xserver/mi/mipolycon.c: File shrank by 0
bytes; padding with zeros

I don't think one should get hung up on the 0 bytes shrinkage, that is
apparently a bug in the calculation in tar. Also I can make gcc fail
with an internal compiler error on another large source tree freshly
checked out from cvs, with the error appearing on the same file every
time. Restarting the compilation then succeeds.    

I've tried most combinations of mount options, but problem persist. 

I can send tcpdumps or output from nfs layer debugging if necessary. It
is quite strange, the particular file does not show up in the debug
messages at all, but it _is_ present in the directory. 

I hope somebody have an idea of what goes wrong.

- Morten

-- 
Morten Sylvest Olsen
System Developer

Medical Insight A/S
Hovedgaden 451 C
DK-2640 Hedehusene, Denmark
Phone: +45-46550444, Mobile: +45-51573092
E-mail: mso@medical-insight.com



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

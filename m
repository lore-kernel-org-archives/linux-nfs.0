From: Andrew Glen-Young <andy@metropolis.co.za>
Subject: statd not binding to outgoing-port
Date: Thu, 24 Oct 2002 18:44:29 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021024164428.GE28138@metropolis.co.za>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from otaku.iac.iafrica.com ([196.7.103.27])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184l65-0002qG-00
	for <nfs@lists.sourceforge.net>; Thu, 24 Oct 2002 09:44:38 -0700
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

Hello All,

I've been through the NFS-HOWTO and have decided to bind the rpc daemons to
specified ports. I have been successful with all but one daemon: rpc.statd.
When I run rpc.statd -p 32765 -o 32766, the daemon correctly binds to port 32765
but not to 32766. Rather it binds to a low numbered port - 761, 833, etc.
Nothing else is bound to the port: 32766. Rpc.statd seems to be ignoring the -o
flag?

I am using Linux 2.4.19 vanilla kernel, portmap v5 and have tried the vanilla
sources for nfs-utils-0.3.3 and nfs-utils-1.0.1, both with the same result.

I was wondering whether this is a bug or mere stupidity...

Thanks for your time,

-- 
=========================================================
Andrew Glen-Young           Phone:        +27 21 426-5252  
iafrica.com                 Fax:          +27 21 426-5453
Systems Administrator       Mail:   andy@metropolis.co.za


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0003en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Robert Heessels" <robert@heessels.com>
Subject: 'random' diskless clients hangs
Date: Wed, 3 Sep 2003 11:26:11 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <NEBBIHNAFKJAFOHBHGCOKEHLEFAA.robert@heessels.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19uTuy-0004oP-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 02:27:12 -0700
Received: from smtp2.mail.be.easynet.net ([212.100.160.76])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19uTux-000123-Sx
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 02:27:12 -0700
Received: from 212-100-181-22.adsl.easynet.be ([212.100.181.22] helo=SHEPHERD)
	by smtp2.mail.be.easynet.net with smtp (Exim 4.22)
	id 19uTuR-0006if-PG
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 11:26:39 +0200
To: <nfs@lists.sourceforge.net>
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

Hello,

We have a setup with a NFS V3 Fileserver and diskless clients all running
Red Hat 7.3.

All clients run fine for days at a time, but every now and then a client
hangs. Most of the time the process that is porbably causing the hang is
either rhn_check (from Red Hat Network) or httpsd with user psaadm (from
Plesk 6.0.1).

Since we are new to NFS we're not sure how to track down this problem. Any
help would be VERY much appreciated!

Kind regards,

Robert Heessels
Alphamega




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

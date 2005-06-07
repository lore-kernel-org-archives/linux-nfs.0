From: Sven Geggus <sven@geggus.net>
Subject: 2.4 -> 2.6 transition major performance issues
Date: Tue, 7 Jun 2005 10:21:26 +0200
Message-ID: <20050607082126.GA17624@geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DfZL4-0005Ye-4A
	for nfs@lists.sourceforge.net; Tue, 07 Jun 2005 01:21:34 -0700
Received: from dolly.gnuher.de ([212.227.64.154])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DfZL2-0004UX-LY
	for nfs@lists.sourceforge.net; Tue, 07 Jun 2005 01:21:34 -0700
Received: from benzin.geggus.net ([2001:8d8:81:672::1])
	by dolly.gnuher.de with esmtpsa TLS-1.0:RSA_AES_256_CBC_SHA:32
	(Exim 4.50 id 1DfZKy-0000GN-1L)
	for <nfs@lists.sourceforge.net>; Tue, 07 Jun 2005 10:21:28 +0200
Received: from sven by benzin.geggus.net with local
	(Exim 4.50 id 1DfZKw-0004h7-AZ)
	for <nfs@lists.sourceforge.net>; Tue, 07 Jun 2005 10:21:26 +0200
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

Hi there,

while trying to update my Debian sarge system from Kernel 2.4. to 2.6 I came
across a very strange Problem with The Kernel NFS-Server.

I use a somewhat slow Machine (666 MHz VIA Samuel) as an NFS-Server for a
diskless Linux Workstation (root-NFS) and home directories.

This works fine as long as the Server is running vanilla 2.4.31. Now, after
updating the Kernel to linux vanilla 2.6.11.10 the System will get almost
unusable if NFS activity occurs! E.g. building a Kernel inside of an
NFS-mounted home-directory gives me a System load of about 2.0 on the
Server.

Compared to Kernel 2.4 the boot-time of the diskless Machine is increased by
a faktor of two running Kernel 2.6.

Do you have any hint where I could start to debug this? I already made
shure, that NFSv3 is used in any case.

Sven

-- 
This golden age of communication Means everyone talks at the same time
(Lyrics of "New Model Army" song "225")

/me is giggls@ircnet, http://sven.gegg.us/ on the Web


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Thanos Chatziathanassiou <tchatzi@arx.gr>
Subject: NFSv3 not supported ?
Date: Sun, 01 Sep 2002 21:01:01 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D7255DD.BFBBA4E5@arx.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pol.arx.gr ([212.205.86.236] helo=www1.arx.gr)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17lZ2c-00039V-00
	for <nfs@lists.sourceforge.net>; Sun, 01 Sep 2002 11:01:42 -0700
Received: from arx.gr (skevos.arx.gr [212.205.86.238])
	by www1.arx.gr (8.9.3/8.9.3) with ESMTP id VAA02524
	for <nfs@lists.sourceforge.net>; Sun, 1 Sep 2002 21:01:21 +0300
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

Hi list, lots of head-banging on this one:
Some time ago, I asked what this message meant:
``NFS: NFSv3 not supported warning: mount version older than kernel''
since my mount was most certainly up-to-date.

Trond answered that I did not specify ``include NFSv3 client support''
when compiling the kernel.

Last night, I decide to upgrade to kernel 2.4.19, when I specifically
remembered to include NFSv3 support, when asked. However, on the next
reboot, upon mount, the same message appeared.

As I figured out just now, the message will appear (although I'm not
sure if it really means what it says) if NFS support is compiled inside
the kernel, but won't appear, if NFS support is compiled as a module
(again, I don't really know if it is indeed NFSv3, but it says it is).

Can anyone explain this ? Is NFSv3 meant to be only compiled as a module
?

Regards,
Thanos Chatziathanassiou




-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

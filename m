From: Tobias Burnus <tobias.burnus@physik.fu-berlin.de>
Subject: Heavy problems with NFS (2.4.20)
Date: Thu, 20 Feb 2003 16:18:23 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302201600090.19940-100000@g31.physik.fu-berlin.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from down.physik.fu-berlin.de ([160.45.34.6])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lsTR-0001fH-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 07:18:57 -0800
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

Hello,

we use NFSv3 with Kernel 2.4.20 which works rather well.
While the main directories (/home, $MAIL, /usr etc.) are either local or
mounted from a HA cluster system, we make heavy use of cross mounted file
systems to save calulation scratch data from Bob to Alice:/discs/scratch/.

This normally works flawlessly, but sometimes such a computer (Alice) has
a hardware or kernel error - or is switched off ("halt",=A0[1]) without
ensuring that no other computer still mounts that disc.

This causes then serious problem: While the nfs client (Bob) computer has
no load visible to the user ("top"), is reacts very, very slow. (Until
either the nfs client is rebooted or the server is alive again.)

Any ideas how we can reduce the inpact?

The directories are mouted with these options:
  rw,nosuid,nodev,intr,addr=3Dxxx.xxx.xxx.xxx

Part of the problem is probably that our default login scripts have things
like "quota" or "df" which seemingly also check those directories
(which are mounted with "noquota").

We use quota with timeout -2, so after 2 seconds it is KILLed (-9), so one
can at least log-in and the system behaves kind of ok -- though it is
very, very slow.

Any ideas?

Tobias

[1] This can happen if the computer is moved into an other room, the
graphics card is changed, etc.; we don't turn our computers off for fun ;-)



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

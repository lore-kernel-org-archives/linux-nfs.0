From: "Nicholas Lafferty" <nlafferty@pennswoods.net>
Subject: fh_verify
Date: Mon, 2 Sep 2002 19:38:24 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <003901c252d9$d92bea70$9300a8c0@gridlock>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.pennswoods.net ([205.247.236.146])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17m0xg-0006sj-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Sep 2002 16:50:28 -0700
Received: from gridlock (du233-637716.dialupcu.pennswoods.net [63.77.16.233])
	by mail.pennswoods.net (Postfix) with SMTP id 3E7612898B0
	for <nfs@lists.sourceforge.net>; Mon,  2 Sep 2002 19:50:12 -0400 (EDT)
To: "nfs" <nfs@lists.sourceforge.net>
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

I have recently set up a lan with three New Internet Computers booting off
the network as outlined in the article (
http://www.dnalounge.com/backstage/src/kiosk ) . After many atempts I have
finally gotten ALMOST a booting client.
I have been alternating testing with SysVinit and Busybox's init. If I use
the normal init I get errors on the NFS server about fh_verify: /etc/shadow
permission failure. As soon as inittab is read. I get the same errors when I
run sulogin. If I rename the inittab out of the way I can only boot in
single mode.

If I use busybox it will boot. But I can not start X and I get the same
errors.

Any clue? Any help would be great.

Nicholas Lafferty





-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

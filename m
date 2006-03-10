From: "Daniel Amthor" <da@lonx.net>
Subject: NFS refusing to perform when backup ISDN link is up
Date: Fri, 10 Mar 2006 10:30:18 +0100 (CET)
Message-ID: <47324.62.159.242.114.1141983018.squirrel@otto.lonx.net>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHdxA-0001IR-0d
	for nfs@lists.sourceforge.net; Fri, 10 Mar 2006 01:30:32 -0800
Received: from subzero.webdirekt.de ([195.243.240.4] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FHdx8-0008Co-K3
	for nfs@lists.sourceforge.net; Fri, 10 Mar 2006 01:30:32 -0800
Received: from localhost (localhost [127.0.0.1])
	by subzero.webdirekt.de (Postfix) with ESMTP id 2AC9365BEB
	for <nfs@lists.sourceforge.net>; Fri, 10 Mar 2006 10:30:21 +0100 (CET)
Received: from subzero.webdirekt.de ([127.0.0.1])
 by localhost (subzero [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 03144-06 for <nfs@lists.sourceforge.net>;
 Fri, 10 Mar 2006 10:30:19 +0100 (CET)
Received: from otto.lonx.net (work.lonx.net [195.243.240.241])
	by subzero.webdirekt.de (Postfix) with ESMTP id DA06B65BEA
	for <nfs@lists.sourceforge.net>; Fri, 10 Mar 2006 10:30:19 +0100 (CET)
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

Hello List,
our setup:
25 Solaris Clients bound to a Linux SLES 9 Server (2.6.5-7-139)
Authentication and NameServices run locally and on as a backup a remote
site connected via Fibre Optics. When the Fibre Link goes down a 384k ISD=
N
backup fails in.
The Scene:
When ISDN failover occurs the local client performance goes down rapidly,
even though all traffic stays local. We get "RPC timeout" as well as some
"Permission denied" in the logs. Quite erratic, sometime it works,
sometimes it does not. I've read the NFS FAQ and figured maybe MTU and
fragmentation, but then all traffic should be local.
Any ideas or experiences ?
Best
Dan



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

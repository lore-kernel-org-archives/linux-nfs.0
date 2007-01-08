From: oudoubah@altern.org
Subject: nfs over ssh : invalid protocol
Date: Mon, 8 Jan 2007 12:36:00 +0100 (CET)
Message-ID: <36900.193.178.136.53.1168256160.squirrel@altern.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H3roW-0007Zi-Vf
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 02:33:13 -0800
Received: from altern.org ([80.67.174.57] helo=filer2.altern.org ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H3roW-00087U-9g
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 02:33:14 -0800
Received: from altern.org (localhost.localdomain [127.0.0.1])
	by filer2.altern.org (Postfix) with ESMTP id 8596B490A553
	for <nfs@lists.sourceforge.net>; Mon,  8 Jan 2007 12:36:00 +0100 (CET)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

I try to mount a nfs share over ssh with this commands (in a script) :
ssh -f -L${NFSPORT}:${IPSERVER}:2049 -L${NFSMOUNTPORT}:${IPSERVER}:32767
-l root ${IPSERVER} sleep 60
mount -t nfs -o
tcp,sync,rsize=8192,wsize=8192,soft,timeo=60,port=$NFSPORT,mountport=$NFSMOUNTPORT
$NOMSERVER:/$REPSERVER $REP

The tunnel is OK. The mount command works on some servers, but on other
servers i have an error message. Here is what i see on the term :
ssh -f -L38000:10.0.0.1:2049 -L38001:10.0.0.1:32767 -l save 10.0.0.1 sleep 60
[OK]
mount -t nfs -o
tcp,sync,rsize=8192,wsize=8192,soft,timeo=60,port=38000,mountport=38001
localhost:/images /tmp/save.11601
mount to NFS server 'localhost' failed: possible invalid protocol.
[KO]

There is a firewall between the two servers, and only the port 22 and 111
are open.

Do you have any idea?

Thanks!

Oudoubah


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

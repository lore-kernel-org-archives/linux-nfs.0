From: sean <seandarcy2@gmail.com>
Subject: server shows client mounted, but client sees permission denied
Date: Sat, 09 Dec 2006 19:38:29 -0500
Message-ID: <elfku6$nvt$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GtDpV-00017i-JM
	for nfs@lists.sourceforge.net; Sat, 09 Dec 2006 17:50:13 -0800
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GtDpV-0006Js-M3
	for nfs@lists.sourceforge.net; Sat, 09 Dec 2006 17:50:15 -0800
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GtDpK-0003B3-17
	for nfs@lists.sourceforge.net; Sun, 10 Dec 2006 02:50:02 +0100
Received: from 69-183-161-241.ded.snet.net ([69.183.161.241])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Sun, 10 Dec 2006 02:50:02 +0100
Received: from seandarcy2 by 69-183-161-241.ded.snet.net with local (Gmexim
	0.1 (Debian)) id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Sun, 10 Dec 2006 02:50:02 +0100
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

Using Fedora Core 6, nfs v3.

  mount -v  my.doc
mount: trying 75.yy.76.28 prog 100003 vers 3 prot tcp port 2049
mount: trying 75.yy.76.28 prog 100005 vers 3 prot udp port 988
mount: linuxbox:/home/transfer/my.doc failed, reason given 
by server: Permission denied

But on the server syslog:

  rpc.mountd: authenticated mount request my.client.net:941 
for /home/transfer/my.doc (/home/transfer/my.doc)

and
cat /var/lib/nfs/etab
/home/transfer/my.doc 
*(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)

cat /var/lib/nfs/rmtab
*:/home/transfer/my.doc:0x00000003

I've flushed iptables. Nothing in hosts.deny. hosts.allow 
has ALL: ALL

Any help really appreciated.

sean


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

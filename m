From: Zhang Weiwu <zhangweiwu@realss.com>
Subject: SFU client cannot connect to Linux NFS server on a network
	without	reverse DNS
Date: Wed, 11 Apr 2007 17:30:28 +0800
Message-ID: <1176283828.24860.27.camel@joe.realss.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbZC2-0004Bq-Ma
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 02:32:47 -0700
Received: from bossdog.realss.com ([211.157.108.128])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbZC1-0003Zd-9Z
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 02:32:49 -0700
Received: from localhost (unknown [127.0.0.1])
	by bossdog.realss.com (Postfix) with ESMTP id 6D7381C0004
	for <nfs@lists.sourceforge.net>; Wed, 11 Apr 2007 17:32:55 +0800 (CST)
Received: from bossdog.realss.com ([127.0.0.1])
	by localhost (bossdog.realss.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 00362-13 for <nfs@lists.sourceforge.net>;
	Wed, 11 Apr 2007 17:32:53 +0800 (CST)
Received: from [218.193.55.195]
	(129.16.61.59.board.xm.fj.dynamic.163data.com.cn [59.61.16.129])
	by bossdog.realss.com (Postfix) with ESMTP id 409EF1C0003
	for <nfs@lists.sourceforge.net>; Wed, 11 Apr 2007 17:32:53 +0800 (CST)
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

I don't know if I should file a bug for Linux's NFS because basically
(as my understanding) this is a bug of Microsoft's SFU NFS client.
However we all know complain to Microsoft means nothing, thus the email
come to nfs list which is the only list might care about Microsoft's
product's users.

I have Linux NFS server set up on FreeBSD for years and I also tried to
deploy Windows SFU NFS client to access the NFS server, which is okay.
(only anonymous export and anonymous mount)

When we (for some special reason) need to move the NFS service to Linux
we got a problem, SFU NFS client complains "Network Path not Found".

MS kb article suggest this is because my network lack reverse DNS, or
better say, because NFS Client is designed to interconnet UNIX but not
Linux NFS server.
http://support.microsoft.com/kb/926095

My /etc/export is:

/var/export    0.0.0.0/0.0.0.0(ro,insecure,no_subtree_check,sync)

My situation is:

     I. It's impossible to set up reverse DNS here because the campus
        has been running for years without it and the network
        administrator will not make any change because of my office.
    II. Linux   client to Linux   NFS server works fine without reverse
        DNS, Linux   client to FreeBSD NFS server works fine without
        reverse DNS, Windows client to FreeBSD NFS server works fine
        without reverse DNS, Windows client to Linux NFS server doesn't
        work without reverse DNS. Why?

I hope there is an option in Linux NFS server that can turn off reverse
DNS for Windows NFS Client though I could not find such an option after
read a lot of related documents. I also tried to adjust SFU NFS client
but there are two few options there for me to tweak.

If currently Linux NFS server cannot work with SFU on a etwork without
reverse DNS, can we file a feature request and hope next version this
will be okay?

P.S. switching NFS client is difficult to me because all other NFS
client than Microsoft's product are for a fee. If this cannot be made
working, the only option for us is to switch to samba which means a lot
of changes in the office.

-- 
Zhang Weiwu
Real Softservice
http://www.realss.com
+86 592 2091112


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

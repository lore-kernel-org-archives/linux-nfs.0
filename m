From: Roman Kagan <rkagan@mail.ru>
Subject: quota ignored on NFS
Date: Sat, 15 Jan 2005 01:31:25 +0300
Message-ID: <1105741885.2328.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpZym-0005fo-Em
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 14:31:40 -0800
Received: from apachihuilliztli.mtu.ru ([195.34.32.124])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CpZyk-00085F-ED
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 14:31:40 -0800
Received: from umail.ru (umail.mtu.ru [195.34.32.101])
	by Apachihuilliztli.mtu.ru (Postfix) with ESMTP id DA84C70018
	for <nfs@lists.sourceforge.net>; Sat, 15 Jan 2005 01:31:27 +0300 (MSK)
	(envelope-from rkagan@mail.ru)
Received: from [83.237.20.164] (HELO ppp83-237-20-164.pppoe.mtu-net.ru)
  by umail.ru (CommuniGate Pro SMTP 4.2b6)
  with ESMTP id 383070312 for nfs@lists.sourceforge.net; Sat, 15 Jan 2005 01:31:27 +0300
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

  Hi,

I'm having trouble using disk quota with NFS mounted filesystems.

When the filesystem accessed locally on the server, the quota works
fine, i.e. nothing can be written over quota.

However, when the same filesystem is accessed over NFS, an user on the
client can write as much as he wants as though the quota system is
bypassed somehow.

Both the server and the client are on 2.6.10 (was the same at least with
2.6.[89]).  The filesystem is ext2 with v2 quota, both NFSv2 and NFSv3,
both tcp and udp (mis)behave the same.

Is that a known problem?  Any hints at the solution are appreciated.

Thanks,
  Roman.



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

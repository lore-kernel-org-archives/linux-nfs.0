From: Dan Ohnesorg <Dan@ohnesorg.cz>
Subject: Group write not working in 2.6.16.X
Date: Mon, 5 Jun 2006 17:54:27 +0200
Message-ID: <20060605155427.GQ27961@ohnesorg.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FnHhr-000753-G2
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 09:13:31 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FnHhr-0000q8-FT
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 09:13:31 -0700
Received: from ns.rudna.net ([212.20.112.2] helo=gate.rudna.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FnHhp-0003ik-QE
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 09:13:31 -0700
Received: from dan.ohnesorg.cz (dan.int.rudna.net [10.7.7.7])
	by gate.rudna.net (Postfix) with ESMTP id E82832090E0C0
	for <nfs@lists.sourceforge.net>; Mon,  5 Jun 2006 17:54:25 +0200 (CEST)
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


I have found strange problem with nfs after upgrading from kernel 2.6.14 to
2.6.16.

System on both ends is Debian Sarge with all patches. We use user space nfs
server.

Problem is, that a file with group write permission is not writable by this
group, lets have a server called server and client called client, on server
export directory /data/export

server# cat /etc/exports
/data/export              192.168.0.2/255.255.255.255(rw,no_root_squash,sync)

and mount them on client

client# mount -t nfs server:/data/export /mnt/data

than try on client

client# cd /mnt/data
client# echo "Hi" > file.txt
client# chmod g+w file.txt
client# su - someuser
client$ cd /mnt/data
client$ echo "Hi2" >> file.txt
-su: test: Permission denied

this problem occures only with kernel 2.6.16 on client side, after reboot to
2.6.14 the append works great with same configuration. Another important hit
is, that the problem is only in directory, where the nfs tree is mounted, on
subdirectories is everythink working properly.

Is this bug or are oldes kernels buggy and now is the situation corrected?

cheers
dan


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

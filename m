From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: how to check if file locking is working?
Date: Thu, 26 Apr 2007 13:29:04 +0200
Message-ID: <46308D00.5040109@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hh2Ao-0000P0-Ss
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 04:30:06 -0700
Received: from mail.syneticon.net ([213.239.212.131] helo=mail2.syneticon.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hh2Aq-0005Xr-6x
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 04:30:09 -0700
Received: from localhost (localhost [127.0.0.1])
	by mail2.syneticon.net (Postfix) with ESMTP id 9FF582A83B
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 13:30:04 +0200 (CEST)
Received: from mail2.syneticon.net ([127.0.0.1])
	by localhost (linux [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 28249-07 for <nfs@lists.sourceforge.net>;
	Thu, 26 Apr 2007 13:29:27 +0200 (CEST)
Received: from postfix1.syneticon.net (postfix1.syneticon.net [192.168.112.6])
	by mail2.syneticon.net (Postfix) with ESMTP
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 13:29:27 +0200 (CEST)
Received: from localhost (filter1.syneticon.net [192.168.113.3])
	by postfix1.syneticon.net (Postfix) with ESMTP id 9519894EA
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 13:39:01 +0200 (CEST)
Received: from postfix1.syneticon.net ([192.168.113.4])
	by localhost (mx03.syneticon.net [192.168.113.3]) (amavisd-new,
	port 10025)
	with ESMTP id w8F4ASTWyR8x for <nfs@lists.sourceforge.net>;
	Thu, 26 Apr 2007 11:25:05 +0000 (UTC)
Received: from [192.168.10.145] (xdsl-87-79-223-24.netcologne.de
	[87.79.223.24]) by postfix1.syneticon.net (Postfix) with ESMTP
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 13:38:59 +0200 (CEST)
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

How can I check if file locking is working?

I have a NFS4 server (Linux x86) and a NFS4 client (Linux ARM).


NFS4 server exports a Debian-ARM root filesystem (/bin, /etc, /usr... a 
complete OS).

I want to "upgrade" the Debian-ARM root filesystem in a NFS4 chroot, but 
it fails - dpkg claims that:

debconf: DbDriver "config": /var/cache/debconf/config.dat is locked by 
another process


It's not true, as that export is only used by that one client.



So what comes to my mind, is that file locking is somehow broken.

How can I check if NFS4 file locking works properly, or is broken?


-- 
Tomasz Chmielewski
http://wpkg.org

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Erik Bryer <erik_bryer@yahoo.com>
Subject: [NFS] how to display fsid on client?
Date: Wed, 13 Jan 2010 14:14:25 -0800 (PST)
Message-ID: <55270.93264.qm@web37306.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54274 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756443Ab0AMWOv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jan 2010 17:14:51 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NVBUH-000699-Du
	for linux-nfs@vger.kernel.org; Thu, 14 Jan 2010 09:14:49 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm using (client and server) CentOS 5 (2.6.18). If I set the fsid to a small integer in the server's exports files (e.g. 1, 19 or 0x10, 0xffff and so on), then exportfs -arf, then unmount and mount on the client, I get the same device number from running ``stat'' on the mount point. It goes like this (client=10.10.99.102):
root@server# cat /etc/exports
/home           10.10.99.102(ro,sync,no_root_squash)
root@client# cat /etc/fstab | grep server
server:/home /n/server/home nfs hard,intr,bg,sync,ro  0 0
root@client# mount /n/server/home
root@client# stat /n/server/home
  File: `/n/server/home'
  Size: 4096            Blocks: 16         IO Block: 4096   directory
Device: 31h/49d Inode: 2           Links: 8
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (  301/   users)
Access: 2010-01-08 14:15:43.000000000 -0500
Modify: 2009-03-09 18:42:01.000000000 -0400
Change: 2009-11-23 19:45:51.000000000 -0500
root@server# cat /etc/exports
/home           10.10.99.102(ro,sync,no_root_squash,sid=0x19)
root@server# exportfs -arf
root@client# umount /n/server/home
root@client# mount /n/server/home
root@client# stat /n/server/home
[ same information as above, specifically the same Device # ]

I've tried this many times, read the faq, and so on. Do I misunderstand? Is the st_dev, "ID of device containing file", as read on the client not going to be the same as what is forced by "fsid=n" in the exports file?


      

------------------------------------------------------------------------------
Throughout its 18-year history, RSA Conference consistently attracts the
world's best and brightest in the field, creating opportunities for Conference
attendees to learn about information security's most important issues through
interactions with peers, luminaries and emerging and established companies.
http://p.sf.net/sfu/rsaconf-dev2dev
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


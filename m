From: Frank Thommen <fthommen@embl.de>
Subject: Copying files to mounted NFS shares blocks file access and
 desktop actions
Date: Wed, 09 May 2007 14:01:51 +0200
Message-ID: <4641B82F.9050107@embl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS Maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlksI-0005Gg-6L
	for nfs@lists.sourceforge.net; Wed, 09 May 2007 05:02:30 -0700
Received: from newmail.embl-heidelberg.de ([194.94.44.200]
	helo=lxmail.EMBL-Heidelberg.DE)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HlksK-0001Tp-D3
	for nfs@lists.sourceforge.net; Wed, 09 May 2007 05:02:32 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

on some of our hosts we have the problem, that copying a file onto an 
NFS share completely blocks the access to this file and even desktop 
actions (opening new terminal, moving windows etc.) with Gnome and KDE 
become merely impossible:


# cp file /mnt/file

a simultaneous `ls -l /mnt` is blocked and finishes only after the copy 
process has finished.  A `strace ls -l /mnt` shows:

# strace ls -l /mnt
[...]
lstat("file",


/mnt is mounted without special options.


We see this behaviour on these systems

  FC5, x86_64, kernel 2.6.19-1.2288.fc5 SMP,
       mount version 'util-linux 2.13-pre7',
       NIC: Broadcom NetXtreme BCM5752 PCI Express (rev 02),
       Speed: 1000Mb/s

  FC5, i686, kernel 2.6.15-1.2054_FC5,
       mount version 'util-linux 2.13-pre6',
       NIC: 3Com Corporation 3c905C-TX/TX-M [Tornado] (rev 74),
       Speed: 100Mb/s

  FC6, x86_64, kernel 2.6.20-1.2944.fc6 SMP,
       mount version 'util-linux 2.13-pre7',
       NIC: Broadcom NetXtreme BCM5752 PCI Express (rev 02),
       Speed: 1000Mb/s


The problem is less pronounced on

  FC5, x86_64, kernel 2.6.18-1.2239.fc5 SMP,
       mount version 'util-linux 2.13-pre7',
       NIC: Broadcom NetXtreme BCM5752 PCI Express (rev 02)
       Speed: 1000Mb/s


No such problems are experienced on:

  FC5, x86_64, kernel 2.6.20-1.2307.fc5 SMP,
       mount version 'util-linux 2.13-pre7',
       NIC: Broadcom Corporation Unknown device 167a (rev 02),
       Speed: 1000Mb/s


It's not a problem of mount options.  Whatever options I use, the 
problem is the same.  Upgrading kernels is not an option, as the x86_64 
systems in questions do not run with 2.6.20 kernels at all. Googling 
around didn't provide any helpful answers.

What can I do to track down the problem in more detail or is there 
perhaps a solution or workaround somewhere in the wild?  I've no 
experiences with making custom kernels, so all other solutions are 
preferred ;-)


Cheers and thanks

    frank

-- 
Frank Thommen - IT Support Structures - EMBL Heidelberg
fthommen@embl.de - +49 6221 387 8353


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

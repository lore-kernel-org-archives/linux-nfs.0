From: Rajat <sharma.rajat@hcl.in>
Subject: NFS Hangs on heavy I/O
Date: Thu, 28 Jun 2007 15:01:03 +0000 (UTC)
Message-ID: <loom.20070628T164810-117@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3vmk-0003RS-Vc
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 08:19:55 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3vmo-0007fJ-2j
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 08:19:58 -0700
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1I3viF-0008W8-PL
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 17:15:16 +0200
Received: from 192.8.220.9 ([192.8.220.9])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Jun 2007 17:15:15 +0200
Received: from sharma.rajat by 192.8.220.9 with local (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Jun 2007 17:15:15 +0200
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

Hi list,

I am facing a NFS hang problem when I perform a very heavy I/O on a localhost 
mount.
The situation is:
$>mount -t nfs localhost:/home/RHL /mnt/nfs

where /home/RHL is a Ext3 Partition (/dev/sda5). Mount paramter was 'hard' by 
default

When I perform a heavy I/O on nfs mount
$> createfile /mnt/nfs/huge_file 512 1048576

Where createfile would try to write 512 blocks of 1048576 bytes each (each 
system call of 1048576, 512 times = 512MB file).

While the file is being created, I tried to ls in the /mnt/nfs directory - and 
it hanged (after creating about 75MB file). Logging from other terminals was 
not working as well.
In my dmesg I found message saying:

"nfs: server localhost not responding, still trying"

[no other NFS related message here.]

After rebooting, I tried the same thing but ls'd /home/RHL rather than nfs 
mount - it hanged again (this time it could create 332MB file). Same message 
was relayed in dmesg. This time I was able to login (though slow) and found 
that 4 nfsd thread were there in ps.
/proc/../status of all of them was "Sleeping" (for 2) or "Disk Sleep" (for 
other 2). All were averaging about 97% sleep (got from /proc/.../status)

I can reproduce this by the same procedure. 

I am running a Intel Machine (Intel(R) Pentium(R) 4 CPU 3.20GHz HT), with 1GB 
RAM, Linux-2.6.19 stock kernel, SATA driver (/dev/sda5) (default)

I tried the same thing multiple times getting the same result (machine did not 
stall always (just a couple of times)- nfs partition and the terminal on which 
I was doing work always stalled).

Can anyone help in giving pointer as to how can I find what is wrong. In case 
you need some specific info, I would be glad to give.

Rajat


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

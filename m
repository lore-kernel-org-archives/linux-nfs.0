From: "Diego A. Fons" <diegofons@apexar.com>
Subject: Problems mounting NFS as root file system
Date: Wed, 23 May 2007 15:44:09 -0300
Message-ID: <46548B79.7020505@apexar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqvsC-00073t-LE
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 11:47:48 -0700
Received: from smtp1.allytech.com ([200.49.145.100] helo=ns1.arsesco.com.ar)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqvsD-000553-46
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 11:47:51 -0700
Received: from [192.168.0.103] (200-55-73-254.dsl.prima.net.ar [200.55.73.254])
	by ns1.arsesco.com.ar (8.13.8/8.13.1) with ESMTP id l4NIfRbA026811
	for <nfs@lists.sourceforge.net>; Wed, 23 May 2007 15:41:27 -0300
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

I'm working on a embedded device (board Ronetix pm9261, core 
AT91SAM9261) i was able to build the linux kernel with NFS support and i 
built Busybox in a root file system wich i want to mount via NFS.

The boot arguments are:
root=/dev/nfs rw rootfstype=nfs 
nfsroot=192.168.0.90:/tftpboot/192.168.0.99 
ip=192.168.0.99::192.168.0.2:255.255.255.0:pm9261:eth0:off 
init=/sbin/init console=ttyS0,115200 debug

The file system mounts OK, but when the boot log shows 'Freeing init 
memory: 112k' it freezes, i think it is a problem when running the init 
program.
I discarded linking problems with the init program (it's static), the 
same program runs ok from he NAND flash file system.
I don't know what to do, i search evrey tutorials and i do the same as they.

Any ideas? suggestions?

Regards,
Diego A. Fons.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Terry Spaulding <spauld@us.ibm.com>
Subject: setting specific lockd port for NFS .....................
Date: Thu, 26 Apr 2007 07:19:34 -0400
Message-ID: <OFEC0E3912.B7B7120F-ON852572C9.003D6E9D-852572C9.003E3796@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hh20q-0007l2-2P
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 04:19:48 -0700
Received: from e4.ny.us.ibm.com ([32.97.182.144])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hh20q-0002ZK-Bv
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 04:19:50 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3QBJIBQ009860
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 07:19:18 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l3QBJIG1531192
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 07:19:18 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l3QBJI1V014405
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 07:19:18 -0400
Received: from d01ml251.pok.ibm.com (d01ml251.pok.ibm.com [9.56.227.119])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	l3QBJIPU014402
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 07:19:18 -0400
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


List....

Has anyone been successful in setting a specific port for lockd to use with
NFS ?

I am using SLES9 SP3 and have tried setting it in /etc/zipl.conf with no
success. It stills uses a port from portmapper rather then a port I am
specifying.

I have tried these two formats in /etc/zipl.conf:

example:

ramdisk = /boot/initrd
    parameters = "root=/dev/mapper/lun01r1 selinux=0 TERM=dumb elevator=cfq
nlm_tcpport=52670 nlm_udpport=52670"


example:

ramdisk = /boot/initrd
    parameters = "root=/dev/mapper/lun01r1 selinux=0 TERM=dumb elevator=cfq
lockd.udpport=52670 lockd.tcpport=52670"

Perhaps I am trying to set it in the wrong place ?

Any recommendations would be appreciated.

TIA .........................

Regards,
Terry L. Spaulding
IBM
spauld@us.ibm.com


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

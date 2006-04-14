From: shashi <shashi.boddula@oracle.com>
Subject: NFS3 in RHEL3
Date: Fri, 14 Apr 2006 11:19:46 +0530
Message-ID: <443F37FA.2060402@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUHCf-0004qt-6P
	for nfs@lists.sourceforge.net; Thu, 13 Apr 2006 22:50:45 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FUHCf-0002NH-3u
	for nfs@lists.sourceforge.net; Thu, 13 Apr 2006 22:50:45 -0700
Received: from rgmgw2.us.oracle.com (rgmgw2.us.oracle.com [138.1.186.111])
	by agminet01.oracle.com (Switch-3.1.7/Switch-3.1.7) with ESMTP id k3E5oZ2b031948
	for <nfs@lists.sourceforge.net>; Fri, 14 Apr 2006 00:50:36 -0500
Received: from [152.69.168.146] (sboddula-idc.idc.oracle.com [152.69.168.146])
	by rgmgw2.us.oracle.com (Switch-3.1.7/Switch-3.1.7) with ESMTP id k3E5oXKX031759
	for <nfs@lists.sourceforge.net>; Thu, 13 Apr 2006 23:50:34 -0600
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

Hi

A small doubt about NFS3 in Linux . If i mount a NFS share (From NetApp
 , ONTAP 6.5 ) on a Linux machine with only ro,nolock options , then
still the NFS mount options like
bg,intr,hard,timeo,wsize,rsize,nfsvers,tcp are still applied ? If they
are applied , how can i check is those are applied or not ?

In my Linux box , after mounting with only ro,nolock options .....

[root@<hostname>]# mount | grep < Mount point>
<NFS server> on < Mount point >  type nfs (ro,nolock,addr=144.20.129.248)

In this case , is other other options like
bg,intr,hard,timeo,wsize,rsize,nfsvers,tcp are applied ? if they are
applied , what are the default values ?

Please answer to my question.

-- 
Thanks & Regards,
Shashi Kanth,SSCP(ISO/IEC17024)


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

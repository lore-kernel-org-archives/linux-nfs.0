From: Terry Spaulding <spauld@us.ibm.com>
Subject: setting up NFS and autofs to use specific ports for nfs,
 lockd, mountd, etc .....
Date: Wed, 18 Apr 2007 07:23:26 -0400
Message-ID: <OF8F2ADFB4.4DFDA634-ON852572C1.003DFCCB-852572C1.003E9244@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1He8Fq-0000rq-8n
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 04:23:18 -0700
Received: from e3.ny.us.ibm.com ([32.97.182.143])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1He8Fs-000680-G2
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 04:23:20 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3IAMFcv011570
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 06:22:15 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l3IBNAZr523580
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 07:23:10 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l3IBNAZ7014761
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 07:23:10 -0400
Received: from d01ml251.pok.ibm.com (d01ml251.pok.ibm.com [9.56.227.119])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	l3IBNAhW014758
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 07:23:10 -0400
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


I am looking to set NFS/autofs to set specific ports at boot time
so that I can request the ports to be open in the firewalls.

I have seen info on setting ports for mountd and nfsd using rpc.mountd and
rpc.nfsd.
The lockd looks to be set in zipl.conf.

Does any one have examples of a script they use to set these ports and
start nfs
for SLES8 and SLES9 or perhaps a link to examples ?

Any examples or links to doc would be greatly appreciated.

Thanks ............

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

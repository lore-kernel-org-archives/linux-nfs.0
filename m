From: Terry Spaulding <spauld@us.ibm.com>
Subject: Re: setting specific lockd port for NFS .....................
Date: Wed, 2 May 2007 12:15:16 -0400
Message-ID: <OFD9943234.0AC40DEC-ON852572CF.00590340-852572CF.005949DD@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjHU7-0003yG-LU
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 09:15:19 -0700
Received: from e6.ny.us.ibm.com ([32.97.182.146])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjHUA-0001yE-0n
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 09:15:22 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l42GG8I7032380
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 12:16:08 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l42GFCk2154990
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 12:15:12 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l42GFCrG005336
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 12:15:12 -0400
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


Neil,

The NFS servers/Clients are working great on SLES8 and SLES9 with static
ports defined
for lockd.

Thanks for the help .....

>Neil,
>
>I found typo on the lockd statement.
>
>I should have set the kernel parms as: parameters="dasd=200-209
>root=/dev/dasda1 lockd.tcpport=52670 lockd.udpport=52670"
>
>Lockd is now set correctly.
>
>On to testing.



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

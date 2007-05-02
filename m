From: Terry Spaulding <spauld@us.ibm.com>
Subject: Re: setting specific lockd port for NFS .....................
Date: Wed, 2 May 2007 08:05:40 -0400
Message-ID: <OF64408285.26F63D4C-ON852572CF.00419070-852572CF.00426FDC@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjDaM-0002pu-CY
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 05:05:30 -0700
Received: from e4.ny.us.ibm.com ([32.97.182.144])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjDaM-00034H-N5
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 05:05:32 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l42C5NBe028830
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 08:05:23 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l42C5NMr523138
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 08:05:23 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l42C5N6h027801
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 08:05:23 -0400
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

I tried the same settings for lockd on the SLES8 system and the lockd
settings do not work in /etc/zipl.conf

I did some research on SLES8 and setting the lockd ports and found some
info that shows the zipl.conf noted
below works for SLES8 but there maybe some additional settings required to
support lockd port setting as a kernel parameter.

I found some references to using sysctl and another to use one of the /etc
conf files but no details on what was entered in these files.

We are planning on replacing all of the SLES8's but later in the year. Can
anyone shed some light on setting the nlm.lockd port on SLES8 ?

Terry Spaulding wrote:
>Neil,
>
>That worked on SLES9. I have the lockd using specific ports.
>
>lockd.nlm_tcpport=52670 lockd.nlm_udpport=52670
>
 >I will be testing the same on SLES8.
>

Thanks................

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

From: Terry Spaulding <spauld@us.ibm.com>
Subject: Re: setting specific lockd port for NFS .....................
Date: Wed, 2 May 2007 09:33:07 -0400
Message-ID: <OFE3F7DAE4.8FFD5934-ON852572CF.0049AC08-852572CF.004A71CA@us.ibm.com>
References: <17976.34907.530222.646539@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjExG-0000B4-1E
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 06:33:14 -0700
Received: from e1.ny.us.ibm.com ([32.97.182.141])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjExI-0002Hy-9j
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 06:33:16 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l42DX3jC003066
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 09:33:03 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l42DX3UT518000
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 09:33:03 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l42DX35j004581
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 09:33:03 -0400
In-Reply-To: <17976.34907.530222.646539@notabene.brown>
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

I changed the zipl.conf. The lockd is still setting the port randomly.

parameters="dasd=200-209 root=/dev/dasda1 lockd_tcpport=52670
lockd_udpport=52670"

ran zipl and rebooted.

Started nfs server on this Linux and issued rpcinfo -p:

    100021    1   udp   1024  nlockmgr
    100021    3   udp   1024  nlockmgr
    100021    4   udp   1024  nlockmgr
    100021    1   tcp   1078  nlockmgr
    100021    3   tcp   1078  nlockmgr
    100021    4   tcp   1078  nlockmgr

rpm -qa | grep nfs:

nfs-utils-1.0.1-79
yast2-nfs-client-2.6.11-51
yast2-nfs-server-2.6.13-41

kernel: Linux linux01 2.4.21-251-default #1 SMP Sun Sep 26 14:07:15 UTC
2004 s390 unknown

Any suggestions would be appreciated.

Thanks .............

>Terry wrote:
> We are planning on replacing all of the SLES8's but later in the year.
Can
> anyone shed some light on setting the nlm.lockd port on SLES8 ?
>Neil wrote:
>SLES8 is 2.4 based which does this a bit differently to 2.6.
>
>Kernel parameters are lockd.udpport and lockd.tcpport
>module parameters are nlm_udpport and nlm_tcpport.
>
?I suspect the former is what you want to put in zipl.conf

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

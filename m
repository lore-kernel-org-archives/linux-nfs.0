From: Terry Spaulding <spauld@us.ibm.com>
Subject: Re: setting specific lockd port for NFS .....................
Date: Tue, 1 May 2007 16:22:19 -0400
Message-ID: <OF1B03D1B8.317A56C3-ON852572CE.006FBB26-852572CE.006FE85A@us.ibm.com>
References: <17971.48667.945682.358155@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hiyrb-0007ei-FL
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 13:22:19 -0700
Received: from e2.ny.us.ibm.com ([32.97.182.142])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiyrY-0003h2-Ot
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 13:22:22 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l41KM7JW004266
	for <nfs@lists.sourceforge.net>; Tue, 1 May 2007 16:22:07 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l41KM6Tg497036
	for <nfs@lists.sourceforge.net>; Tue, 1 May 2007 16:22:06 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l41KM5di005165
	for <nfs@lists.sourceforge.net>; Tue, 1 May 2007 16:22:05 -0400
In-Reply-To: <17971.48667.945682.358155@notabene.brown>
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

That worked on SLES9. I have the lockd using specific ports.

lockd.nlm_tcpport=52670 lockd.nlm_udpport=52670

 I will be testing the same on SLES8.

Thanks................

On Thursday April 26, spauld@us.ibm.com wrote:
>
> List....
>
> Has anyone been successful in setting a specific port for lockd to use
with
> NFS ?

I've never tried it myself, but...

>
> ramdisk = /boot/initrd
>     parameters = "root=/dev/mapper/lun01r1 selinux=0 TERM=dumb
elevator=cfq
> nlm_tcpport=52670 nlm_udpport=52670"
>
>
> example:
>
> ramdisk = /boot/initrd
>     parameters = "root=/dev/mapper/lun01r1 selinux=0 TERM=dumb
elevator=cfq
> lockd.udpport=52670 lockd.tcpport=52670"

>I think you want to combine those two:
>
>    lockd.nlm_tcpport=52670 lockd.nlm_udpport=52670

> NeilBrown


Regards,
Terry L. Spaulding
SR IT Specialist
IBM ITS
Tele: 781-323-5192    Tie/L: 364-2090
Fax: 781-895-2659
spauld@us.ibm.com

"The third-rate mind is only happy when it is thinking with the majority.
The second-rate mind is only happy when it is thinking with the minority.
The first-rate mind is only happy when it is thinking." -- A.A. Milne
(1882-1956)


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

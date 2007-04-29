From: Terry Spaulding <spauld@us.ibm.com>
Subject: Re: setting specific lockd port for NFS .....................
Date: Sun, 29 Apr 2007 10:47:08 -0400
Message-ID: <OF5AE13AC8.71ACFE3D-ON852572CC.0050E148-852572CC.00513856@us.ibm.com>
References: <17971.48667.945682.358155@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiAg3-00063U-7J
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 07:47:03 -0700
Received: from e5.ny.us.ibm.com ([32.97.182.145])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiAg3-0000Ju-UW
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 07:47:06 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3TEkpG8024203
	for <nfs@lists.sourceforge.net>; Sun, 29 Apr 2007 10:46:51 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l3TEkpj8513206
	for <nfs@lists.sourceforge.net>; Sun, 29 Apr 2007 10:46:51 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l3TEkoEG026306
	for <nfs@lists.sourceforge.net>; Sun, 29 Apr 2007 10:46:51 -0400
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

Neil Brown responded on 4/28/2007:
>
>I think you want to combine those two:
>
>    lockd.nlm_tcpport=52670 lockd.nlm_udpport=52670
>
>NeilBrown

Thanks Neil, I will give it a try and get back to the list.


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

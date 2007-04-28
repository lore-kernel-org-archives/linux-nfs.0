From: Neil Brown <neilb@suse.de>
Subject: Re: setting specific lockd port for NFS .....................
Date: Sun, 29 Apr 2007 07:35:23 +1000
Message-ID: <17971.48667.945682.358155@notabene.brown>
References: <OFEC0E3912.B7B7120F-ON852572C9.003D6E9D-852572C9.003E3796@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Terry Spaulding <spauld@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hhua6-0004mD-6x
	for nfs@lists.sourceforge.net; Sat, 28 Apr 2007 14:35:50 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hhua7-0002Gr-8W
	for nfs@lists.sourceforge.net; Sat, 28 Apr 2007 14:35:52 -0700
In-Reply-To: message from Terry Spaulding on Thursday April 26
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
> Has anyone been successful in setting a specific port for lockd to use with
> NFS ?

I've never tried it myself, but...

> 
> ramdisk = /boot/initrd
>     parameters = "root=/dev/mapper/lun01r1 selinux=0 TERM=dumb elevator=cfq
> nlm_tcpport=52670 nlm_udpport=52670"
> 
> 
> example:
> 
> ramdisk = /boot/initrd
>     parameters = "root=/dev/mapper/lun01r1 selinux=0 TERM=dumb elevator=cfq
> lockd.udpport=52670 lockd.tcpport=52670"

I think you want to combine those two:

    lockd.nlm_tcpport=52670 lockd.nlm_udpport=52670

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

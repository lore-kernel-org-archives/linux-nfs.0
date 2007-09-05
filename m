From: Terry Spaulding <spauld@us.ibm.com>
Subject: NFS intermittent permission error on NFS mounted
	filesystem.....
Date: Wed, 5 Sep 2007 12:48:29 -0400
Message-ID: <OFD67EE5FF.B29AE590-ON8525734D.005ADB3D-8525734D.005C5492@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ISy2v-0002J7-UX
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 09:48:08 -0700
Received: from e4.ny.us.ibm.com ([32.97.182.144])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ISy30-0002SD-8W
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 09:48:10 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l85Gm10j004749
	for <nfs@lists.sourceforge.net>; Wed, 5 Sep 2007 12:48:01 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id
	l85Gm01N545774
	for <nfs@lists.sourceforge.net>; Wed, 5 Sep 2007 12:48:00 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l85Gm0CO031816
	for <nfs@lists.sourceforge.net>; Wed, 5 Sep 2007 12:48:00 -0400
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


List,

We get on occasion a permission error when we do a cd into an NFS mounted
filesystem on an NFS client.
The steps to correct have been on the NFS Client do a umount and mount.of
the NFS filesystem.
After that the permission problem goes away.

Is this a known problem with NFS with the version I am running ?
Is it corrected in the newer version that is available on the Novell
patches website ?  (newer version is nfs-utils-1.0.6-103.28)

Message received:

NFSbob@Linux02 $ cd /opt/tivoli/z1/zdev
ksh: cd: /opt/tivoli/z1/zdev - Permission denied
NFSbob@Linux02 $


The Linux hosts systems are SLES9 SP3 with additional maint.

NFS is at:  nfs-utils-1.0.6-103.23
kernel is at:  2.6.5-7.276-s390


The NFS filesystem is mounted thru the /etc/fstab:

Linux01:/opt/tivoli/zdev      /opt/tivoli/z1/zdev     nfs      intr  0 0
Linux02:/ #


Mount display on the Client:

Linux02:/ # mount
/dev/mapper/mproot1 on / type ext3 (rw,acl,user_xattr)
proc on /proc type proc (rw)
sysfs on /sys type sysfs (rw)
tmpfs on /dev/shm type tmpfs (rw)
devpts on /dev/pts type devpts (rw,mode=0620,gid=5)
/dev/mapper/mpboot1 on /boot type ext3 (rw,acl,user_xattr)
/dev/mapper/rootvg-usr on /usr type ext3 (rw,acl,user_xattr)
/dev/mapper/rootvg-var on /var type ext3 (rw,acl,user_xattr)
/dev/mapper/rootvg-opt on /opt type ext3 (rw,acl,user_xattr)
/dev/mapper/rootvg-home on /home type ext3 (rw,acl,user_xattr)
/dev/mapper/ITM6VG-tivlv1 on /opt/tivoli type ext3 (rw,acl,user_xattr)
Linux01:/opt/tivoli/zdev on /opt/tivoli/z1/zdev type nfs
(rw,intr,addr=10.64.77.28)
Linux02:/ #

Any thoughts or recommendations would be greatly appreciated.

TIA ................

Regards,
Terry L. Spaulding
spauld@us.ibm.com


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

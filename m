From: "Edwards, Scott (GE Healthcare)" <J.Scott.Edwards@ge.com>
Subject: NFS hangs for 15 seconds after exportfs -r
Date: Thu, 12 Jan 2006 18:05:09 -0600
Message-ID: <C664ABFF405D6A458806C03AA2E0FF6B06CBC733@MKEMLVEM01.e2k.ad.ge.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExCRg-0000Cb-IR
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 16:05:32 -0800
Received: from ext-ch1gw-8.online-age.net ([64.37.194.16])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ExCRg-0000K7-5E
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 16:05:32 -0800
Received: from int-ch1gw-4.online-age.net (int-ch1gw-4 [3.159.232.68])
	by ext-ch1gw-8.online-age.net (8.13.4/8.13.5/20051111-SVVS-TLS-DNSBL) with ESMTP id k0D05BGS014125
	for <nfs@lists.sourceforge.net>; Thu, 12 Jan 2006 19:05:11 -0500
Received: from cinmlef01.e2k.ad.ge.com (localhost [127.0.0.1])
	by int-ch1gw-4.online-age.net (8.12.9/8.12.3/990426-RLH) with ESMTP id k0D059gf012349
	for <nfs@lists.sourceforge.net>; Thu, 12 Jan 2006 19:05:10 -0500 (EST)
To: <nfs@lists.sourceforge.net>
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


We have a strange problem with the 2.6.9 kernel and NFS hanging for =
several seconds after upgrading.

We have been running Fedora Core 2 for about two years on a system.  =
This system has two processors, one running an RTOS and the other was =
running the 2.6.6 kernel.  The RTOS is diskless and mounts a partition =
on the Linux drive via NFS.  It also mounts the CD-ROM drive under it's =
partition when a disc is mounted.  When the CD is mounted we run an =
"exportfs -r" command to export the CD.  The system worked fine with =
Fedora Core 2 and the 2.6.6 kernel.

Lately we have been trying to upgrade to a newer version of Linux 2.6.9 =
kernel, with the RHEL clones (WhiteBox and CentOS).  On both of these =
systems after a CD is inserted the RTOS hangs for around 15 seconds =
waiting for NFS to reply.  We have tried removing "exportfs -r" and then =
there is no perceivable delay.  However the reason that is in there is =
so that the newly mounted CD is exported so we need to have that.

Is this a known problem with the 2.6.9 Kernel?  I searched the archives =
and found a couple of e-mails about the 2.6.9 kernel hanging after an =
"exportfs -ra", but it hung completely and never came back.

Any advice would be most appreciated.

Thanks
  -Scott




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

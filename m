From: Victor Sterpu <victor@ambra.ro>
Subject: Mounting a partition at boot time from /etc/fstab
Date: Thu, 16 Aug 2007 11:55:05 +0300
Message-ID: <46C410E9.2030809@ambra.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILb6k-0001Ay-CO
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 01:53:34 -0700
Received: from mail.ambra.ro ([86.107.248.1])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILb6n-0004CD-Ai
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 01:53:38 -0700
Received: from localhost (localhost [127.0.0.1])
	by mail.ambra.ro (Postfix) with ESMTP id D2A734786A
	for <nfs@lists.sourceforge.net>; Thu, 16 Aug 2007 11:52:32 +0300 (EEST)
Received: from mail.ambra.ro ([127.0.0.1])
	by localhost (mail68 [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 02089-07 for <nfs@lists.sourceforge.net>;
	Thu, 16 Aug 2007 11:52:19 +0300 (EEST)
Received: from [80.97.24.235] (ppp249780235.ambra.ro [80.97.24.235])
	by mail.ambra.ro (Postfix) with ESMTP id 6F913479C6
	for <nfs@lists.sourceforge.net>; Thu, 16 Aug 2007 11:52:19 +0300 (EEST)
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

I try to mount the /var partition at boot time.

I receive the following error at boot time:
statd: server localhost not responding, time out
lockd: cannot monitor 192.168.250.90
lockd: failed to monitor 192.168.250.90

This is my /etc/fstab :
proc            /proc           proc    defaults        0       0
192.168.250.90:/var/nfs/mail2.ambra.ro /var nfs defaults 0 0

When I do "mount 192.168.250.90:/var/nfs/mail2.ambra.ro /var" the 
partition is mounted succesfuly.
I use kernel 2.6.20 with nfs and automount support.

Haw can I mount this nfs partition at boot time?
Thank you.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

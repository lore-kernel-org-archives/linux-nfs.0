From: =?UTF-8?Q?Piotr_Kandziora?= <raveen@tlen.pl>
Subject: (no subject)
Date: Mon, 06 Aug 2007 15:45:20 +0200
Message-ID: <790ff6e2.6e7bd4bd.46b725f0.c2373@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II2tg-0001F5-V3
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 06:45:24 -0700
Received: from rekin18.go2.pl ([193.17.41.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II2tj-0006j8-OQ
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 06:45:29 -0700
Received: from o2.pl (unknown [10.0.0.76])
	by rekin18.go2.pl (Postfix) with SMTP id C636453DD6
	for <nfs@lists.sourceforge.net>; Mon,  6 Aug 2007 15:45:20 +0200 (CEST)
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

Dear All,

Hi, I have some issue with NFS exporting. I am using Debian with 2.6.17-13 kernel, NFS 1.0.9, portmap 5-9 and LVM2 as NFS server. I have also a share which is exported via NFS. When I extend Logical Volume where the share is located on my clients I have to re-mount the share, but not on all.
Debian and Gentoo distribution can handle with this, but on Mandriva, Ubuntu and Solaris systems I get "NFS file handle", when I tro to access to it.
According to my investigation it is not related to kernel or portmap versions of clients.

-work good(without remounting):
    -Debian with portmap 6-0 and 2.6.21 kernel
    -Gentoo with portmap 5-0 and 2.6.16 kernel
-did not work - remount was needed:
    -Mandriva with portmap 4-0 and 6-0 and 2.6.17 kernel
    -Ubuntu with portmap 5-0 2.6.20 kernel

Did I miss something? What is this related to? Please help - in my environment we have many Linux clients different distribution and it is not desired to remount. I must also mention that the same behaviour I get after restarting the server.

Best Regards

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

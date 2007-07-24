From: Simon Gao <gao@schrodinger.com>
Subject: Autofs failed auto umounting NFS shares exported by Solaris 10
Date: Mon, 23 Jul 2007 21:15:54 -0700
Message-ID: <46A57CFA.2010507@schrodinger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDBog-0001AJ-0G
	for nfs@lists.sourceforge.net; Mon, 23 Jul 2007 21:16:11 -0700
Received: from thermidore.schrodinger.com ([192.156.98.99]
	helo=schrodinger.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IDBoi-0008NL-Ll
	for nfs@lists.sourceforge.net; Mon, 23 Jul 2007 21:16:13 -0700
Received: from toni.schrodinger.com (toni.schrodinger.com [192.156.98.56])
	by schrodinger.com (8.13.4/8.13.4) with ESMTP id l6O4G0XF032146
	for <nfs@lists.sourceforge.net>; Mon, 23 Jul 2007 21:16:00 -0700 (PDT)
	(envelope-from gao@schrodinger.com)
Received: from [10.10.18.38] (sub22-20.member.dsl-only.net [63.105.22.20])
	(authenticated bits=0)
	by toni.schrodinger.com (8.13.3/8.13.3) with ESMTP id l6O4FxkZ012167
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Mon, 23 Jul 2007 21:16:00 -0700 (PDT)
	(envelope-from gao@schrodinger.com)
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

Hi,

I am seeing RHEL/CentOS 5.0 machine failed to un-mount NFS share 
exported by Solaris 10 after time out period:

Here are errors logged:


Jul 23 20:14:45 client1 automount[1801]: umount_multi: could not stat fs 
of /nfs/zfs
Jul 23 20:19:48 client1 automount[1801]: umount_multi: could not stat fs 
of /nfs/zfs
Jul 23 20:24:51 client1 automount[1801]: umount_multi: could not stat fs 
of /nfs/zfs
Jul 23 20:29:54 client1 automount[1801]: umount_multi: could not stat fs 
of /nfs/zfs
Jul 23 20:34:57 client1 automount[1801]: umount_multi: could not stat fs 
of /nfs/zfs
Jul 23 20:40:00 client1 automount[1801]: umount_multi: could not stat fs 
of /nfs/zfs
Jul 23 20:45:03 client1 automount[1801]: umount_multi: could not stat fs 
of /nfs/zfs
Jul 23 20:50:06 client1 automount[1801]: umount_multi: could not stat fs 
of /nfs/zfs
Jul 23 20:55:09 client1 automount[1801]: umount_multi: could not stat fs 
of /nfs/zfs
Jul 23 21:00:12 client1 automount[1801]: umount_multi: could not stat fs 
of /nfs/zfs


The autofs version is autofs-5.0.1-0.rc2.43.0.2.

Anyone has seen similar problem?

Simon

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

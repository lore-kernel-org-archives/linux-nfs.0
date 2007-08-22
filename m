From: Chuck Lever <chuck.lever@oracle.com>
Subject: mount.nfs: chk_mountpoint()
Date: Wed, 22 Aug 2007 15:02:35 -0400
Message-ID: <46CC884B.1030207@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030107080909060600070701"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INvUx-0007wC-DN
	for nfs@lists.sourceforge.net; Wed, 22 Aug 2007 12:04:11 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1INvUx-0000mG-O3
	for nfs@lists.sourceforge.net; Wed, 22 Aug 2007 12:04:13 -0700
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l7MJ3mNZ003829
	for <nfs@lists.sourceforge.net>; Wed, 22 Aug 2007 14:03:49 -0500
Received: from acsmt351.oracle.com (acsmt351.oracle.com [141.146.40.151])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id
	l7M3AZV4002928
	for <nfs@lists.sourceforge.net>; Wed, 22 Aug 2007 13:03:48 -0600
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

This is a multi-part message in MIME format.
--------------030107080909060600070701
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi all-

The recent addition of the chk_mountpoint() function in 
utils/mount/mount.c in nfs-utils commit 3b55934b has broken a particular 
behavior of background mounts.

nfs(5) states that, if the "bg" option is specified, "A missing mount 
point is treated as a timeout, to allow for nested NFS mounts."

If I try mounting an NFS share onto a non-existent directory while using 
the "bg" option, I now get an immediate failure:

   mount.nfs: mount point /mnt/nothere does not exist

instead of the mount backgrounding itself to wait for /mnt/nothere to 
show up.  This is because chk_mountpoint() is causing the mount request 
to fail immediately.

Is the documented bg retry behavior still desirable?

--------------030107080909060600070701
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------030107080909060600070701
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------030107080909060600070701
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030107080909060600070701--

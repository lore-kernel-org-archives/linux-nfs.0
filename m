From: Chuck Lever <chuck.lever@oracle.com>
Subject: BUG: mount.nfs and "bg"
Date: Thu, 02 Aug 2007 13:02:02 -0400
Message-ID: <46B20E0A.1050409@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090207040601030709010501"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGe5Y-0001nK-HF
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 10:03:55 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGe5a-0000Cd-5a
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 10:03:56 -0700
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id
	l72H3kUC010640
	for <nfs@lists.sourceforge.net>; Thu, 2 Aug 2007 11:03:46 -0600
Received: from acsmt351.oracle.com (acsmt351.oracle.com [141.146.40.151])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id
	l72FQWZa010547
	for <nfs@lists.sourceforge.net>; Thu, 2 Aug 2007 11:03:45 -0600
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
--------------090207040601030709010501
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I've finally found a system that has the legacy mount command with NFS 
support built into it, so I've been able to start testing "bg" behavior 
in mount.nfs.  The old system is Fedora Core 5, with /bin/mount.  The 
new system is Fedora 7 and uses /sbin/mount.nfs.

I did a simple test.  On the NFS server I did a "service nfs stop", then 
tried a mount with "-o bg" from each client.  Results:

On FC5, the mount backgrounded immediately, and succeeded once I did a 
"service nfs start" on the server.  A "ps -ef | grep mount" shows a 
backgrounded mount process that goes away once the mount is successful.

On F7, the mount fails immediately with EX_FAIL.  There is no background 
mount process, according to ps.

I plan to study the legacy mount command to understand exactly what 
needs to be added to mount.nfs to make bg mounts work again.

--------------090207040601030709010501
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


--------------090207040601030709010501
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------090207040601030709010501
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090207040601030709010501--

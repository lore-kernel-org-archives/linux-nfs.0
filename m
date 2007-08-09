From: Chuck Lever <chuck.lever@oracle.com>
Subject: inconsistencies in nfs(5)
Date: Thu, 09 Aug 2007 11:08:34 -0400
Message-ID: <46BB2DF2.1050501@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020405000104080309080508"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJ9e1-0003zy-AA
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 08:09:49 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJ9e1-0007BU-OJ
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 08:09:53 -0700
Received: from agmgw1.us.oracle.com (agmgw1.us.oracle.com [152.68.180.212])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id
	l79F9QRa014223
	for <nfs@lists.sourceforge.net>; Thu, 9 Aug 2007 09:09:26 -0600
Received: from acsmt350.oracle.com (acsmt350.oracle.com [141.146.40.150])
	by agmgw1.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id
	l780XGhb029893
	for <nfs@lists.sourceforge.net>; Thu, 9 Aug 2007 09:09:25 -0600
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
--------------020405000104080309080508
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trying to get a handle on how individual mount options behave, I'm 
rewriting nfs(5).  Jeff Layton pointed out a few inconsistencies and 
I've found a few more.  I'd like to resolve these:

+  The default "intr" behavior for nfs and nfs4 is not the same. 
According to the code, for nfs the default is "nointr" and for nfs4 the 
default is "intr".  Is this the desired behavior?

+  "nocto" and "noac" are listed as valid nfs4 mount options.  I believe 
"nocto" can't be supported by the NFSv4 protocol because an OPEN on the 
wire is always necessary.  Is "noac" supported for nfs4 file systems?

+  Is the "noacl" option still supported in 2.6.latest?  What exactly 
does it do, and what are the consequences of using it?

+  The description for the "bg" option claims "After a mount operation 
is backgrounded, all subsequent mounts on the same NFS server will be 
backgrounded immediately, without first attempting the mount."  I don't 
think there's logic to do that in either the legacy mount command or in 
mount.nfs.  Should this text be removed from the man page?

Likely more to come...

--------------020405000104080309080508
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


--------------020405000104080309080508
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------020405000104080309080508
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020405000104080309080508--

From: Chuck Lever <chuck.lever@oracle.com>
Subject: cel's patch series for 2.6.21
Date: Thu, 26 Apr 2007 15:50:30 -0400
Message-ID: <46310286.1000807@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050706060701090205070203"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhA0l-0007mI-2A
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 12:52:15 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HhA0m-00083e-Ck
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 12:52:17 -0700
Received: from rgmgw3.us.oracle.com (rgmgw3.us.oracle.com [138.1.186.112])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id
	l3QJq7E0020917
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 13:52:08 -0600
Received: from acsmt350.oracle.com (acsmt350.oracle.com [141.146.40.150])
	by rgmgw3.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l3QIamh7021710
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 13:52:07 -0600
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

This is a multi-part message in MIME format.
--------------050706060701090205070203
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Announcing the availability of cel's NFS patch series for Linux 2.6.21 
kernels.  This patch series includes the following experimental features:

     * Support for rpcbind protocol versions 3 and 4 in the Linux kernel 
RPC bind client
     * Some support for IPv6 addressing in the Linux NFS client and server
     * Removal of the BKL from the Linux NFS and RPC clients
     * Support for parsing mount option strings in the NFS client 
instead of in the user-space mount command
     * Support for separate client-side cache invalidation logic for 
each version of the NFS protocol
     * Part of a rewrite of the Linux NFS client and server XDR encoding 
and decoding routines


Please see the release notes posted here for details:

http://oss.oracle.com/~cel/linux-2.6/2.6.21/release-notes.html

The patch series is also available in the "cel-pub-2.6.21" branch of 
cel's git repository on linux-nfs.org:

http://linux-nfs.org/cgi-bin/gitweb.cgi?p=cel-2.6.git;a=shortlog;h=cel-pub-2.6.21

--------------050706060701090205070203
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
email;internet:chuck.lever@nospam-oracle.com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel/
version:2.1
end:vcard


--------------050706060701090205070203
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------050706060701090205070203
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050706060701090205070203--

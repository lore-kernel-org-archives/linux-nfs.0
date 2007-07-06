From: Chuck Lever <chuck.lever@oracle.com>
Subject: maintainership question about nfs-utils/util/mount
Date: Fri, 06 Jul 2007 16:13:23 -0400
Message-ID: <468EA263.5010909@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060804040103040905070208"
To: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6uC8-0000hv-1s
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 13:14:24 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I6uCA-00059m-GG
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 13:14:27 -0700
Received: from rgmgw1.us.oracle.com (rgmgw1.us.oracle.com [138.1.186.110])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l66KEEmT024747
	for <nfs@lists.sourceforge.net>; Fri, 6 Jul 2007 15:14:14 -0500
Received: from acsmt351.oracle.com (acsmt351.oracle.com [141.146.40.151])
	by rgmgw1.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l669wcaq020250
	for <nfs@lists.sourceforge.net>; Fri, 6 Jul 2007 14:14:12 -0600
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
--------------060804040103040905070208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I'm looking at nfs-utils/utils/mount in order to patch in support for 
passing a string of mount options to the kernel instead of an 
nfs_mount_data.

In mount.c, main() invokes nfsmount() in nfsmount.c.  nfsmount() defines 
a structure on the stack called "data", then returns a pointer to "data" 
which is then passed to the kernel by main().

I think the only way this continues to work is that there are three 1024 
character buffers defined in nfsmount()'s stack frame before "data," 
which places "data" far enough up the stack that subsequent function 
calls in main() don't smash it.

Although this doesn't cause bad behavior today, it needs to be fixed to 
prevent future changes from breaking things badly.

Also found an interesting error message in here:

   permission died - no match for fstab

Should probably be "permission denied".  I'm not really sure what "no 
match for fstab" means, but looking at the context, this message appears 
if a non-root user tries to mount something that isn't already listed in 
/etc/fstab.

What's the current blessed procedure for sending patches and fixes for 
this particular code?  Mail to agud@redhat.com (last touch rule, and 
author of mount.c) is rejected.

--------------060804040103040905070208
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
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------060804040103040905070208
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------060804040103040905070208
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060804040103040905070208--

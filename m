From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs_refresh_inode: inode number mismatch
Date: Tue, 11 Sep 2007 13:09:08 -0400
Message-ID: <46E6CBB4.7020503@oracle.com>
References: <46E6C54F.4020100@aristoslogic.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000702010902070209050205"
Cc: nfs@lists.sourceforge.net
To: Chris Carlson <c.carlson@aristoslogic.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IV9GJ-0002Eq-0U
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 10:10:55 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IV9GN-0000zO-B1
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 10:10:59 -0700
In-Reply-To: <46E6C54F.4020100@aristoslogic.com>
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
--------------000702010902070209050205
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Chris-

Chris Carlson wrote:
> We are running MontaVista Embedded Linux 2.4 with NetApps NFS servers as 
> the root filesystem and Linux 2.6 mounted filesystems.  A simple test 
> runs to copy files from one mount point to another (both are different 
> directories on the same NFS server mounted at differet points).
> 
> After 30 copies of a hundred files are made, the system is rebooted and 
> the test repeats.
> 
> After 2 reboots, an NFS file is created, and we get the following error 
> from the kernel:
> 
> nfs_refresh_inode: inode number mismatch
> expected (0x11/0xdacea3), got (0x11/0xb8d5e3)
> 
> We're just trying to figure out what to do to figure out what the 
> problem is.  Is there a good place to place printks or breakpoints?

This may be due to an RPC XID collision.  Which 2.4 kernel are you 
using?  The Linux NFS client may be sending the same XID sequence on the 
same port number after each reboot, in which case the server will 
respond with a cached reply rather than doing real work.  The cached 
reply may contain old file ID information, which triggers the "inode 
number mismatch" message you see in your log.

One way to detect if this is happening is to use "pktt" on the filer. 
You can capture a packet trace across client reboots to determine if

A) the transport socket's port number is the same across reboots, and

B) the RPC XID sequence is the same

--------------000702010902070209050205
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


--------------000702010902070209050205
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------000702010902070209050205
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000702010902070209050205--

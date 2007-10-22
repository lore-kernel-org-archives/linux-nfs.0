From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFSv4, SSH etc.
Date: Mon, 22 Oct 2007 13:15:13 -0400
Message-ID: <471CDAA1.7070205@oracle.com>
References: <4qlKQmD9fHHHFwKt@agrotera.halldom.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010803030003000807000901"
Cc: nfs@lists.sourceforge.net
To: Chris Hall <chris@halldom.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ik19d-0000bH-2j
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 10:33:29 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ik19i-0003O5-Bi
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 10:33:34 -0700
In-Reply-To: <4qlKQmD9fHHHFwKt@agrotera.halldom.com>
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
--------------010803030003000807000901
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Chris Hall wrote:
> Help !  I am failing to set up a secure NFS server.  (Generally thought
> to be impossible by most sources !)
> 
> I am running a fully up to date Fedora 7.
> 
>   kernel-2.6.22.9-91.fc7
>   nfs-utils-lib-1.0.8-10.fc7
>   nfs-utils-1.1.0-3.fc7
>   libtirpc-0.1.7-9.fc7
>   rpcbind-0.1.4-6.fc7
> 
> I have been trying to get NFSv4 working between a client on the inside
> of my firewall and a server on the outside (DMZ).
> 
>  a. I thought NFSv4 would be better because it apparently only requires
>     the one TCP port, which is easier to manage.  This turns out not to
>     be entirely the case -- umount appears to still want to talk to port
>     111 to find mountd.

This is a known bug in nfs-utils-1.1.0, and was addressed in 
nfs-utils-1.1.1, just released last week.  NFSv4 certainly doesn't need 
to talk to mountd.  The umount.nfs[4] command was changed to skip the 
mountd step when unmounting "nfs4" file systems.

--------------010803030003000807000901
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


--------------010803030003000807000901
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------010803030003000807000901
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010803030003000807000901--

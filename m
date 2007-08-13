From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: inconsistencies in nfs(5)
Date: Mon, 13 Aug 2007 10:18:37 -0400
Message-ID: <46C0683D.9090906@oracle.com>
References: <46BB2DF2.1050501@oracle.com>
	<169a.46bb3b18.7157f@altium.nl>	<169a.46bb3b18.7157f@altium.nl>
	<46BB405B.5050206@oracle.com> <5e6a.46bc1f6e.593b@altium.nl>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090907030903060200040608"
Cc: nfs@lists.sourceforge.net
To: Dick Streefland <dick.streefland@altium.nl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKdoB-0007mW-FG
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 10:34:27 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKdoE-0007w8-Dj
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 10:34:31 -0700
In-Reply-To: <5e6a.46bc1f6e.593b@altium.nl>
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
--------------090907030903060200040608
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

rnews@tasking.nl wrote:
> Chuck Lever <chuck.lever@oracle.com> wrote:
> | This is still in utils/mount/nfsmount.c.
> 
> It is not in util-linux-ng-2.13-rc2 anymore, which is in Debian sid.
> 
> | I'm not sure how this can affect other mount commands running 
> | concurrently on the same client.  The man page implies that if one mount 
> | command has backgrounded against a server, subsequent mount commands 
> | against the same server will just go right into the background.  But 
> | prev_bg_host is unique in each instance of the mount command.
> | 
> | Can you help me understand what you intended?  Do you have a test case?
> 
> Phew, I wrote that 10 years ago! But I think that when you do a
> "mount -atnfs", multiple mounts will be handled by the same mount
> instance. The code helps when there are multiple NFS mounts from the
> same host in fstab, and the server is down when you boot the client.

OK, that makes sense.  I will try to clarify the sense of nfs(5) to 
reflect this behavior.

--------------090907030903060200040608
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


--------------090907030903060200040608
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------090907030903060200040608
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090907030903060200040608--

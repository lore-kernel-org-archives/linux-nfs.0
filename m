From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount.nfs: restore admin-specified
	clientaddr	option
Date: Thu, 30 Aug 2007 15:23:25 -0400
Message-ID: <46D7192D.9090904@oracle.com>
References: <20070830174620.3799.1497.stgit@monet.1015granger.net>
	<1188500090.7891.8.camel@gaula.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090901050302090708020008"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQpcx-0006sQ-EI
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 12:24:27 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQpd0-0003J2-KW
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 12:24:32 -0700
In-Reply-To: <1188500090.7891.8.camel@gaula.trondhjem.org>
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
--------------090901050302090708020008
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> 'clientaddr' was set up because there is no way for the kernel (or an
> automated userland mount program) to determine exactly which IP address
> the server should be using for callbacks in the case where there are
> more than 1 options.
> That all depends on the local network topology, and routing policies,
> which may not be visible to the client.

The patch corrects a mistaken assumption I made while working on the 
text-based mount implementation.  The broken behavior is only a week or 
so old, doesn't affect legacy nfs4_mount_data style mounts, and was 
never part of an nfs-utils release.

It would be wonderful if we had some of these requirements written down 
somewhere, so we wouldn't be dependent on individuals who are 
unavailable at times when we need some historical perspective.  I've 
started doing this here:

http://wiki.linux-nfs.org/wiki/index.php/NewMountDesignSpec

You have to admit that existing mount option documentation is pretty 
scant on history and rationale.  Look at what nfs(5) says about 
clientaddr= :

> clientaddr=n   On a multi-homed client, this causes the client to use a
>                specific callback address when communicating with an NFS
>                version 4 server.  This option is currently ignored.

"This option is currently ignored."  Ummm....

And Neil just fixed the "multi-homed" part of mount's automated 
clientaddr generation.

And nfs(5) doesn't say Jack about NAT routers or network topology or 
routing policies.

I will send in a patch that also corrects nfs(5).

--------------090901050302090708020008
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


--------------090901050302090708020008
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------090901050302090708020008
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090901050302090708020008--

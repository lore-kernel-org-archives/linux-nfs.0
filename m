From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/9] mount.nfs: Don't allow the user to specify
 addr= or clientaddr=.
Date: Fri, 24 Aug 2007 14:16:40 -0400
Message-ID: <46CF2088.3080903@oracle.com>
References: <20070824171116.10418.56059.stgit@monet.1015granger.net>
	<20070824172529.GA6690@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040005020801040304010704"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOdj6-0002Oa-8S
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 11:17:44 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IOdj9-0003x7-CV
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 11:17:48 -0700
In-Reply-To: <20070824172529.GA6690@fieldses.org>
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
--------------040005020801040304010704
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Fri, Aug 24, 2007 at 01:11:16PM -0400, Chuck Lever wrote:
>> The current mount.nfs implementation doesn't allow users to specify their
>> own addr= or clientaddr= option.
> 
> Don't we need clientaddr= in some cases to get the callback channel
> working?

The mount.nfs command adds a clientaddr option of its own before doing 
the syscall.  The point of the patch is to prevent passing in a 
user-created clientaddr=.

Does anyone know of a use case where an exposed clientaddr= is needed?

>> The new string-based interface does allow this, even though nfs(5)
>> does not document 'addr=' and specifically forbids adding
>> 'clientaddr='.
> 
> It says that it's currently ignored, which isn't the same as forbidding
> it.

nfs(5) is likely incorrect.  It's arguable what "currently ignored" 
means -- it probably means the mount command ignores it, if specified, 
and uses its own address anyway.

--------------040005020801040304010704
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


--------------040005020801040304010704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------040005020801040304010704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040005020801040304010704--

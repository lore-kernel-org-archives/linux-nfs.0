From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/4] mount.nfs: mount's background daemon	should
 free "mount_point" properly
Date: Wed, 22 Aug 2007 01:10:47 -0400
Message-ID: <46CBC557.7070108@oracle.com>
References: <20070821161902.4373.67197.stgit@monet.1015granger.net>
	<20070821221940.GA20987@uio.no>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010705000208040507040109"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INiV3-0001qr-W1
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 22:11:26 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1INiV7-0003DD-2C
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 22:11:30 -0700
In-Reply-To: <20070821221940.GA20987@uio.no>
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
--------------010705000208040507040109
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Steinar H. Gunderson wrote:
> On Tue, Aug 21, 2007 at 12:19:02PM -0400, Chuck Lever wrote:
>>  		 * Parent exits immediately with success.  Make
>> -		 * sure not to free "mount_point"
>> +		 * sure parent doesn't free "mount_point".
> 
> What made this change?

Nothing, I'm clarifying my original comment here.  I just didn't have 
time to test the additional free() before I submitted the first bg patches.

Before any of this was added, there was no free'ing of mount_point at 
all -- mount.nfs left exit() processing to free everything.

--------------010705000208040507040109
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


--------------010705000208040507040109
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------010705000208040507040109
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010705000208040507040109--

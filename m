From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: umount fails with device busy
Date: Thu, 23 Aug 2007 16:32:50 -0400
Message-ID: <46CDEEF2.8040309@oracle.com>
References: <20070823184544.237460@gmx.net> <46CDE805.4090909@oracle.com>
	<20070823201414.GB4692@localhost>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050803070005010907040704"
Cc: nfs@lists.sourceforge.net
To: Zoot <z00t@gmx.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOJNk-0003EK-DK
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 13:34:20 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IOJNn-00058k-HG
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 13:34:24 -0700
In-Reply-To: <20070823201414.GB4692@localhost>
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
--------------050803070005010907040704
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Zoot wrote:
>> This is normal and expected behavior.  One problem may be that your 
>> server is slow, and thus there are RPCs left outstanding for a bit on 
>> your client after your application exits.  The COMMIT calls from that 
>> trace suggest that there is dirty data the client is writing back to the 
>> server.
> But I had expected that umount blocks until the commit calls are
 > finished as it is with local file systems?

Sorry, it doesn't.  It has no way of knowing how long those RPCs will take.

There is a "lazy unmount" facility that removes the NFS share from your 
client's name space and handles the outstanding RPCs in the background. 
  I'm not sure if it's working, but you could try "umount -l".

--------------050803070005010907040704
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


--------------050803070005010907040704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------050803070005010907040704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050803070005010907040704--

From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount.nfs: Update description of clientaddr= in
 nfs(5)
Date: Fri, 31 Aug 2007 09:54:50 -0400
Message-ID: <46D81DAA.6070009@oracle.com>
References: <20070830194810.4524.58037.stgit@monet.1015granger.net>
	<46D75CE7.2020605@oxeva.fr>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030905080809030208020604"
Cc: nfs@lists.sourceforge.net
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR6z3-0005KW-6g
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 06:56:25 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IR6z6-0006c5-7f
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 06:56:29 -0700
In-Reply-To: <46D75CE7.2020605@oxeva.fr>
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
--------------030905080809030208020604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Gabriel Barazer wrote:
> On 08/30/2007 9:48:10 PM +0200, Chuck Lever <chuck.lever@oracle.com> wrote:
>> The description of clientaddr= in nfs(5) is out of date and omits some
>> other typical reasons for using it.  Let's start with this rewrite.
> 
> By the way, can we update the man page date show the current version 
> somewhere ? This is a bit disturbing to see "20 November 1993" at the 
> bottom of the man page, and would clear minds about the "ignored at this 
> time" or "not implemented yet" : does the word "currently" makes any 
> sense, when the only date showed is 15 years ago ?

As part of the new text-based mount work, I'm designing a complete 
replacement for nfs(5).  You can view a partially complete version of 
the new document here:

http://wiki.linux-nfs.org/wiki/index.php/NewNfsManPage

It's in the wiki so others can review, comment, and participate.

--------------030905080809030208020604
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


--------------030905080809030208020604
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------030905080809030208020604
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030905080809030208020604--

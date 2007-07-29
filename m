From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 01/23] mount.nfs: Support double-wide characters
 in printed strings
Date: Sun, 29 Jul 2007 16:05:06 -0400
Message-ID: <46ACF2F2.80602@oracle.com>
References: <20070728214913.21871.41624.stgit@localhost.localdomain>
	<18092.17434.520955.494157@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060409000300040207040906"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFF2L-0003UP-Oz
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 13:06:45 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFF2O-0004fD-Dd
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 13:06:49 -0700
In-Reply-To: <18092.17434.520955.494157@notabene.brown>
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
--------------060409000300040207040906
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

> So please either show me the error of my thinking, or stick to adding
> _() to translatable strings.
> 
> Much of this patch is good and wanted, I'm not sure about the whole.
> Similarly for patch 2.

Yeah, the options stuff was a mistake which I thought I had avoided. 
Will fix all this up and post a fresh patch set.

But my impression was a double-byte "." is not the same as a single-byte 
".".  I'm not an expert, and would be happy if someone (like a 
distributor) had an internationalization expert they could loan us.

> I only got 12 of the 23 patches??

The list didn't see half of these either.  Will investigate.  I probably 
shut down my laptop before it was done relaying the patches.

--------------060409000300040207040906
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


--------------060409000300040207040906
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------060409000300040207040906
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060409000300040207040906--

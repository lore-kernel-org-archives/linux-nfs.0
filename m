From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 03/20] SUNRPC: Fix some signed v. unsigned
 comparisons in xprtsock.c
Date: Mon, 13 Aug 2007 10:10:29 -0400
Message-ID: <46C06655.6030706@oracle.com>
References: <20070806155636.31233.33750.stgit@manray.1015granger.net>
	<1186843423.17941.18.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090909050205060707080201"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKdmY-0007Z1-Eu
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 10:32:46 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKdmb-0007wa-Cx
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 10:32:50 -0700
In-Reply-To: <1186843423.17941.18.camel@heimdal.trondhjem.org>
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
--------------090909050205060707080201
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Mon, 2007-08-06 at 11:56 -0400, Chuck Lever wrote:
>> Currently these are not harmful because the range of "len" is less than the
>> size of a page.
> 
> NACK. It is always safe to test an unsigned quantity against a signed
> quantity for equality, _provided_ that the two quantities are the same
> size. Since we're comparing an unsigned int to an int, that is clearly
> the case here.
> 
> The explicit cast is not only unnecessary, but it is actually bad, since
> it may obscure any future comparison errors should we ever for some
> reason decide to change the size of err.

As an aside, the purpose of the patches fixing these casts is not just 
to correct run-time bugs, but also to eliminate compiler and sparse 
warnings, which in some cases are simply extraneous noise due to 
compiler pickiness, but can sometimes be nasty bugs (as we found out in 
fs/nfs/direct.c, recently).

Eventually I think we should use sparse as part of a check-in test 
suite, and -Wall all the time for building both fs/nfs and net/sunrpc, 
as this setting does catch valid bugs.  In that event, eliminating 
spurious compiler and sparse warnings will cut down on noise and make it 
easy to spot new problems as we are developing.

--------------090909050205060707080201
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


--------------090909050205060707080201
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------090909050205060707080201
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090909050205060707080201--

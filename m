From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: build problems with latest nfs-utils
Date: Sun, 15 Jul 2007 22:05:02 -0400
Message-ID: <469AD24E.9050508@oracle.com>
References: <469AB4D6.20902@oracle.com> <20070716013119.GA14612@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080203080209070301070506"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAFxu-0003dy-Mp
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 19:05:34 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAFxx-0002Dm-3K
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 19:05:38 -0700
In-Reply-To: <20070716013119.GA14612@fieldses.org>
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
--------------080203080209070301070506
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Sun, Jul 15, 2007 at 07:59:18PM -0400, Chuck Lever wrote:
>> I updated my git repo to the latest version of nfs-utils, and now I can no 
>> longer build nfs-utils.  I use
>>
>> ./configure --disable-gss --disable-nfsv4
>>
>> and get these compilation errors:
> 
> Whoops, yes, I didn't think to test my changes with gss or nfsv4
> disabled.  I'll take a look at this tomorrow; thanks for noticing that.
> 
> --b.

;-)

Yep, thought so.

A build-test / check-in test suite for some of these utilities is 
bumbling around in the back of my brain.  We'll see if it breaches the 
laziness threshold and I get around to constructing something.

Anyone else thought much about this?  One thing that would be nice to 
test is whether we've broken support over the years for the very old 
versions of nfs_mount_data (both mount command and NFS client processing).

--------------080203080209070301070506
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle USA;Corporate Architecture
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------080203080209070301070506
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------080203080209070301070506
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080203080209070301070506--

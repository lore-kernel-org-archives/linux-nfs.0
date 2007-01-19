From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 01/14] NFS: fix print format for tk_pid
Date: Thu, 18 Jan 2007 19:10:44 -0500
Message-ID: <45B00C84.7030809@oracle.com>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118232925.23310.31437.stgit@localhost.localdomain>
	<20070119000319.GA13473@infradead.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080802020600030506030603"
Cc: trond.myklybust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7hN6-0008BC-JH
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 16:12:44 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7hN6-0006C9-Qt
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 16:12:46 -0800
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20070119000319.GA13473@infradead.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------080802020600030506030603
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Christoph Hellwig wrote:
> On Thu, Jan 18, 2007 at 06:29:27PM -0500, Chuck Lever wrote:
>> The tk_pid field is an unsigned short.  The proper print format specifier for
>> that type is %5u, not %4d.
>>
>> Also clean up some miscellaneous print formatting nits.
> 
> Once you cleanup all these printks please make sure to add line breaks
> after at most 80 characters.

For the record, I think I was careful to do this, but I don't have a 
neat little tool like Neil does to verify line length explicitly.

--------------080802020600030506030603
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture Linux Projects Group
email;internet:chuck dot lever at nospam oracle dot com
title:Principle Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------080802020600030506030603
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------080802020600030506030603
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080802020600030506030603--

From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 12/14] SUNRPC: RPC buffer size estimates are too
 large
Date: Thu, 18 Jan 2007 18:54:48 -0500
Message-ID: <45B008C8.6080601@oracle.com>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233052.23310.25010.stgit@localhost.localdomain>
	<20070118234956.GC14242@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060204090608040409020803"
Cc: trond.myklybust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7h6p-0005hU-RN
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:55:55 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7h6p-0002LL-Ew
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:55:57 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20070118234956.GC14242@fieldses.org>
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
--------------060204090608040409020803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Thu, Jan 18, 2007 at 06:30:53PM -0500, Chuck Lever wrote:
>> The RPC buffer size estimation logic in net/sunrpc/clnt.c always
>> significantly overestimates the requirements for the buffer size.
>> A little instrumentation demonstrated that in fact rpc_malloc was never
>> allocating the buffer from the mempool, but almost always called kmalloc.
>>
>> To compute the size of the RPC buffer more precisely, split p_bufsiz into
>> two fields; one for the argument size, and one for the result size.  The
>> goal is to keep the size requirement for RPC buffers at or below 2KiB.
>>
>> So now we will compute the sum of the exact call and reply header sizes,
>> and split the RPC buffer precisely between the two.  That should keep all
>> RPCs within the 2KiB buffer mempool limit.
>>
>> And, we can finally be rid of RPC_SLACK_SPACE!
> 
> I'm a little worried about krb5, and especially the integrity and
> privacy code--I don't think this accounts for the space they need.
> 
> I'm not sure how best to estimate their requirements....

If the RPC header field size definitions are correct, the verifiers are 
defined as 400 bytes (100 quads).  There should be room enough for the 
largest verifiers.

--------------060204090608040409020803
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


--------------060204090608040409020803
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------060204090608040409020803
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060204090608040409020803--

From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 13/14] NLM: Shrink the maximum request size of
 NLM4 requests
Date: Fri, 19 Jan 2007 17:27:13 -0500
Message-ID: <45B145C1.5080007@oracle.com>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233056.23310.1289.stgit@localhost.localdomain>
	<20070119001355.GD13473@infradead.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030803000901030603070503"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H82Dn-00027O-LR
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 14:28:31 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H82Dn-0001Kn-7t
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 14:28:33 -0800
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20070119001355.GD13473@infradead.org>
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
--------------030803000901030603070503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Christoph Hellwig wrote:
> On Thu, Jan 18, 2007 at 06:30:56PM -0500, Chuck Lever wrote:
>> NLM version 4 requests estimate the call and reply header sizes rather
>> conservatively, using the very maximum size allowed in the protocol even
>> though Linux always uses only a small fraction of the allowable space.
>>
>> Reduce the size of caller and lock arguments to conserve RPC buffer space
>> while XDR encoding NLM4 arguments..
> 
>> +#ifndef MIN
>> +# define MIN(a, b)	(((a) < (b)) ? (a) : (b))
>> +#endif
> 
> please use the kernel min or min_t macros instead.

min/min_t don't work for integer constants, which is what I'm using 
MIN() for.  What should I use instead?


--------------030803000901030603070503
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


--------------030803000901030603070503
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------030803000901030603070503
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030803000901030603070503--

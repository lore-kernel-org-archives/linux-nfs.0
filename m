From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 10/14] SUNRPC: Enable support for rpcbind versions
 3 and 4 via CONFIG options
Date: Fri, 19 Jan 2007 17:04:13 -0500
Message-ID: <45B1405D.2000804@oracle.com>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233045.23310.43704.stgit@localhost.localdomain>
	<20070119001131.GC13473@infradead.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040309060800040908080608"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H81s4-0008Ap-US
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 14:06:05 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H81s6-0007XE-9b
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 14:06:06 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20070119001131.GC13473@infradead.org>
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
--------------040309060800040908080608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Christoph Hellwig wrote:
>> +config RPCBIND_VERSION4
>> +	bool "Support for rpcbind version 4"
> 
> Do we really need two config options for this?

I can easily combine these into a single option, but actually, do we 
need any config option at all?  Trond, why not leave versions 3 and 4 
enabled all the time?

--------------040309060800040908080608
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


--------------040309060800040908080608
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------040309060800040908080608
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040309060800040908080608--

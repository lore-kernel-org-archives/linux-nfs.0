From: Chuck Lever <chuck.lever@ORACLE.COM>
Subject: Re: reply cache
Date: Mon, 15 Oct 2007 12:57:16 -0400
Message-ID: <47139BEC.8030400@oracle.com>
References: <47139B20.7070805@cesca.es>
Reply-To: chuck.lever@ORACLE.COM
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060809090605010002060209"
Cc: nfs@lists.sourceforge.net
To: Jordi Prats <jprats@cesca.es>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhUTX-00059g-Si
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 11:15:36 -0700
Received: from rgminet02.oracle.com ([148.87.113.119])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IhUTc-0004hk-ME
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 11:15:41 -0700
Received: from rgminet01.oracle.com (rgminet01.oracle.com [148.87.113.118])
	by rgminet02.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l9FGxcbY021230
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Mon, 15 Oct 2007 11:00:04 -0600
In-Reply-To: <47139B20.7070805@cesca.es>
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
--------------060809090605010002060209
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Jordi Prats wrote:
> According to the file fs/nfsd/nfscache.c (line 30 on 2.6.23), reply 
> cache is fixed size. Why is this a fixed size cache? Shouldn't be 
> relative to the number of nfsd threads? I've a server with this statistics:
> 
> rc 0 959398 336415498
> 
> By what I've been researching this means: 0 hits, 959398 misses (I 
> supose that means something like "recently deleted") and 336415498 not 
> in cache (and never has been). Is that right?

A DRC hit implies the client is retransmitting.  Not having any hits is 
a good thing -- it means your server is able to handle all your clients 
without much sweat.

> Modifying the CACHESIZE to a bigger size do you think it could enhance 
> NFS performance by getting some hits on the reply cache?

The server's DRC is not a performance feature.  It's a way for the 
server to detect replayed requests from the client.  In a perfect world, 
servers wouldn't even have one.

--------------060809090605010002060209
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
version:2.1
end:vcard


--------------060809090605010002060209
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------060809090605010002060209
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060809090605010002060209--

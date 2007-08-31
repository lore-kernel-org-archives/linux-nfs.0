From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] [PATCH] rpcbind netid declared per-transport
Date: Fri, 31 Aug 2007 12:59:39 -0400
Message-ID: <46D848FB.6070409@oracle.com>
References: <EXNANE01Mb1s7nlT2Nq00000219@exnane01.hq.netapp.com>
	<46D820F8.6040309@oracle.com>
	<1188570399.6649.83.camel@heimdal.trondhjem.org>
	<46D825EB.90801@oracle.com>
	<1188573228.6649.100.camel@heimdal.trondhjem.org>
	<46D835F4.4030703@oracle.com>
	<EXNANE01hjJ8uT6Ssuo00000243@exnane01.hq.netapp.com>
	<46D84176.5020807@oracle.com>
	<EXNANE01FlmmlQ080Gx00000245@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040000020307050005030100"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR9s6-0001tG-DC
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 10:01:29 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IR9s8-0004Sq-Jc
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 10:01:31 -0700
In-Reply-To: <EXNANE01FlmmlQ080Gx00000245@exnane01.hq.netapp.com>
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
--------------040000020307050005030100
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Talpey, Thomas wrote:
> At 12:27 PM 8/31/2007, Chuck Lever wrote:
>> Talpey, Thomas wrote:
>>> "RPCB_" prefix: They're (with this patch) part of the rpcbind api. The prefix
>> ...
>> It's a nit, I guess.
> 
> How about RPCBIND_NETID_foo? It's more obvious, and keeps the RPC...

OK by me.

>>> RPCB_MAXNETIDLEN: Sure, I'll move it. It is, after all, a limit on the string
>>> ...
>> We need to know the maximum size to compute the largest possible size of 
>> the RPC buffer needed for the request.  See the definition of 
>> RPCB_netid_sz.  Those are all added together to get the largest possible 
>> request size, and that's used to compute the largest possible buffer size.
> 
> Yes, I know, but it could be larger and more dynamically calculated.

I'm not sure what you mean, then.  The buffer size maximums are 
statically computed at kernel compile time.

--------------040000020307050005030100
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


--------------040000020307050005030100
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------040000020307050005030100
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040000020307050005030100--

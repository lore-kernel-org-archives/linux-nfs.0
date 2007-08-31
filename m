From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] [PATCH] rpcbind netid declared per-transport
Date: Fri, 31 Aug 2007 10:30:03 -0400
Message-ID: <46D825EB.90801@oracle.com>
References: <EXNANE01Mb1s7nlT2Nq00000219@exnane01.hq.netapp.com>	
	<46D820F8.6040309@oracle.com>
	<1188570399.6649.83.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010709030902040503020508"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR7XI-0000Nr-60
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 07:31:48 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IR7XM-0006Yf-C4
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 07:31:52 -0700
In-Reply-To: <1188570399.6649.83.camel@heimdal.trondhjem.org>
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
--------------010709030902040503020508
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Fri, 2007-08-31 at 10:08 -0400, Chuck Lever wrote:
> 
>>>  
>>> +/*
>>> + * RFC1833/RFC3530 rpcbind (v3+) well-known netid's.
>>> + */
>>> +#define	RPCB_NETID_UDP	"\165\144\160"		/* "udp" */
>>> +#define	RPCB_NETID_TCP	"\164\143\160"		/* "tcp" */
>>> +#define	RPCB_NETID_UDP6	"\165\144\160\066"	/* "udp6" */
>>> +#define	RPCB_NETID_TCP6	"\164\143\160\066"	/* "tcp6" */
> 
> BTW: Any reason why we are using escaped octal instead of plain ascii
> here?

Is there a guarantee that these C strings will be US-ASCII on *every* 
platform in every locale on which Linux kernels are built?  Z-series, 
for example?

If yes, then we can use a normal string.

--------------010709030902040503020508
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


--------------010709030902040503020508
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------010709030902040503020508
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010709030902040503020508--

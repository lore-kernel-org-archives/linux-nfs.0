From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Use of delayed request information in nlmsvc_lookup_host
Date: Thu, 15 Nov 2007 12:00:59 -0500
Message-ID: <473C7B4B.4060402@oracle.com>
References: <473B3D0B.3060204@oracle.com>	
	<1195065798.7584.37.camel@heimdal.trondhjem.org>	
	<473B45C9.4060708@oracle.com>	
	<1195069262.7584.54.camel@heimdal.trondhjem.org>	
	<473B5278.7090408@oracle.com>
	<18235.41907.383911.722103@notabene.brown>	
	<473C4FE2.1090402@oracle.com>
	<1195142050.7506.13.camel@heimdal.trondhjem.org>
	<473C7344.5090705@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090107050305060208000509"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Isi7O-0002VV-G2
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 09:03:06 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Isi7T-0000KI-3A
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 09:03:12 -0800
In-Reply-To: <473C7344.5090705@oracle.com>
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
--------------090107050305060208000509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



Chuck Lever wrote:
> Trond Myklebust wrote:
>> On Thu, 2007-11-15 at 08:55 -0500, Chuck Lever wrote:
>>
>>> What do you think of changing the rq_daddr field to be a 
>>> sockaddr_storage?
>>
>> Why? You've already got rq_addr.
> 
> rq_daddr stores raw address bits, but nlm_host stores a whole sockaddr 
> for the source address.  Should we change nlm_host to store just the raw 
> address bits as well (svc_addr_u)?  AFAICS the only place that needs to 
> construct a whole sockaddr out of the source address is nlm_bind_host.

I'll answer my own e-mail question.

nlm_host{} has to store a full address because nlm_lookup_host() uses 
nlm_cmp_addr() to compare the source addresses.  nlm_cmp_addr() has to 
be address-family-aware.

--------------090107050305060208000509
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


--------------090107050305060208000509
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------090107050305060208000509
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090107050305060208000509--

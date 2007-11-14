From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Use of delayed request information in nlmsvc_lookup_host
Date: Wed, 14 Nov 2007 14:54:32 -0500
Message-ID: <473B5278.7090408@oracle.com>
References: <473B3D0B.3060204@oracle.com>	
	<1195065798.7584.37.camel@heimdal.trondhjem.org>	
	<473B45C9.4060708@oracle.com>
	<1195069262.7584.54.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020804070805060407040709"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsOKn-0002rQ-Ol
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 11:55:37 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsOKr-0003TC-EN
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 11:55:43 -0800
In-Reply-To: <1195069262.7584.54.camel@heimdal.trondhjem.org>
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
--------------020804070805060407040709
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Wed, 2007-11-14 at 14:00 -0500, Chuck Lever wrote:
>> That's correct.  I'm just trying to understand why, historically, 
>> rq_daddr was just the 32-bit address and not a full sockaddr to begin 
>> with.  There may be something we're missing, like "we didn't want to add 
>> another large field to this structure due to memory alignment or 
>> allocation efficiency concerns".  :-)
> 
> Actually, rq_daddr by definition pretty much has to be of the same
> address family as rq_addr, since they are the two endpoints for the same
> socket. 
> 
> However I can't see where rq_addr is being initialised for UDP sockets.
> That is sort of worrying given that it is used among other things by the
> nfsd duplicate reply cache...

That's the other half of my question.  Why isn't nlmsvc_lookup_host 
using rq_addr (without the d)?

--------------020804070805060407040709
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


--------------020804070805060407040709
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------020804070805060407040709
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020804070805060407040709--

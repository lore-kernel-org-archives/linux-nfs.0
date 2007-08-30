From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 00/20] svc: Server Side Transport Switch
Date: Thu, 30 Aug 2007 17:12:49 -0400
Message-ID: <46D732D1.3070008@oracle.com>
References: <C2FB1E3A.3A83F%tom@opengridcomputing.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050009040802070700050107"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQrK5-0000gh-J3
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 14:13:05 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQrK8-0000cU-P4
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 14:13:10 -0700
In-Reply-To: <C2FB1E3A.3A83F%tom@opengridcomputing.com>
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
--------------050009040802070700050107
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit



Tom Tucker wrote:
> [...snip...]
>>> For example,
>>>
>>> # echo rdma 2050 > /proc/fs/nfsd/portlist
>>>
>>> Will cause the knfsd daemon to attempt to add a listening endpoint on
>>> port 2050 using the 'rdma' transport.
>> Does this also register the new endpoint with the server's portmapper,
>> or is there an additional step required for this?  At least for RDMA I
>> assume the portmapper registration is not needed, but other transports
>> may want it.
> 
> No it doesn't, but IMO it needs to. The reason it doesn't is that the
> current portmapper registration service doesn't look at the netid, it looks
> at the protocol number and maps that to a netid internally. I think this is
> broken, but that's what it does. Since RMDA doesn't have an IP protocol, I
> couldn't map it with the current services.
> 
> I think the right thing to do is to modify the rpcb_register service to take
> a netid and set it in the rpc_msg, and modify the portmapper to honor the
> netid specified. 

Version 2 of the rpcbind protocol doesn't take a netid.  To register a 
netid with the local portmapper, you need two things to happen:

1.  The local portmapper needs to be something that can take v3 or v4 
registration requests

2.  rpcb_register needs to be converted to use v3 or v4 of the rpcbind 
protocol to do the registering.

3.  Mr. Talpey needs to submit his patch to make RPC transport 
implementations support RPC_DISPLAY_NETID so the rpcbind client has a 
proper netid string to send to the local rpcbind daemon.

Thing 1 seems to be happening as distributions start using the new 
rpcbind daemon to replace the old portmapper.

Thing 2 can happen easily after thing 1 is commonplace.

Thing 3 is under development.

--------------050009040802070700050107
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


--------------050009040802070700050107
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------050009040802070700050107
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050009040802070700050107--

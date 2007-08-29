From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 00/20] svc: Server Side Transport Switch
Date: Wed, 29 Aug 2007 12:50:38 -0400
Message-ID: <46D5A3DE.8030208@oracle.com>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020407010501030105070707"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQQmN-00056a-CX
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 09:52:31 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQQmP-0008SK-Jg
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 09:52:35 -0700
In-Reply-To: <20070820162000.15224.65524.stgit@dell3.ogc.int>
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
--------------020407010501030105070707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Tom-

Tom Tucker wrote:
> This patchset represents an update to the previously published 
> version. The most significant changes are a renaming of the 
> transport switch data structures and functions based on a 
> recommendation from Chuck Lever. Code cleanup was also done in the
> portlist implementation based on feedback from Trond. Additionally, 
> the synopsis for the register/unregister services were changed
> to return errors and module reference counting was added. 
> 
> I've included the original description below for new reviewers.
> 
> This patchset implements a sunrpc server side pluggable transport 
> switch that supports dynamically registered transports. 
> 
> The knfsd daemon has been modified to allow user-mode programs 
> to add a new listening endpoint by writing a string
> to the portlist file. The format of the string is as follows:
> 
> <transport-name> <port>
> 
> For example,
> 
> # echo rdma 2050 > /proc/fs/nfsd/portlist
> 
> Will cause the knfsd daemon to attempt to add a listening endpoint on 
> port 2050 using the 'rdma' transport.

Does this also register the new endpoint with the server's portmapper, 
or is there an additional step required for this?  At least for RDMA I 
assume the portmapper registration is not needed, but other transports 
may want it.

> Transports register themselves with the transport switch using a
> new API that has the following synopsis:
> 
> int svc_register_transport(struct svc_sock_ops *xprt)

As before, the "sock" in svc_sock_ops might be better left out for what 
is ostensibly a generic data structure.

> The text transport name is contained in a field in the xprt structure.
> A new service has been added as well to take a transport name
> instead of an IP protocol number to specify the transport on which the 
> listening endpoint is to be created. This function is defined as follows:
> 
> int svc_create_svcsock(struct svc_serv, char *transport_name, 
>                        unsigned short port, int flags);

Again, "sock" should be sensibly excised from the function name.

> The existing svc_makesock interface was left to avoid impacts to existing 
> servers. It has been modified to map IP protocol numbers to transport 
> strings.

I think the client and server should use the *same* mechanism for 
matching transports -- either a string *or* a protocol number (not 
necessarily the IPPROTO number, but something mapped to it, so we can 
add transport types like RDMA that don't have an IPPROTO number already).

How do others feel about this?  String, or protocol number?

--------------020407010501030105070707
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
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------020407010501030105070707
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------020407010501030105070707
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020407010501030105070707--

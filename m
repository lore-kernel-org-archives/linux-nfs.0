From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 00/20] svc: Server Side Transport Switch
Date: Wed, 29 Aug 2007 12:59:38 -0500
Message-ID: <C2FB1E3A.3A83F%tom@opengridcomputing.com>
References: <46D5A3DE.8030208@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQRiD-0002qK-Gu
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:52:17 -0700
Received: from mail.es335.com ([67.65.19.105])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQRiH-0005Yo-OO
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:52:22 -0700
In-Reply-To: <46D5A3DE.8030208@oracle.com>
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

[...snip...]
>> 
>> For example,
>> 
>> # echo rdma 2050 > /proc/fs/nfsd/portlist
>> 
>> Will cause the knfsd daemon to attempt to add a listening endpoint on
>> port 2050 using the 'rdma' transport.
> 
> Does this also register the new endpoint with the server's portmapper,
> or is there an additional step required for this?  At least for RDMA I
> assume the portmapper registration is not needed, but other transports
> may want it.
> 

No it doesn't, but IMO it needs to. The reason it doesn't is that the
current portmapper registration service doesn't look at the netid, it looks
at the protocol number and maps that to a netid internally. I think this is
broken, but that's what it does. Since RMDA doesn't have an IP protocol, I
couldn't map it with the current services.

I think the right thing to do is to modify the rpcb_register service to take
a netid and set it in the rpc_msg, a modify the portmapper to honor the
netid specified. 

>> Transports register themselves with the transport switch using a
>> new API that has the following synopsis:
>> 
>> int svc_register_transport(struct svc_sock_ops *xprt)
> 
> As before, the "sock" in svc_sock_ops might be better left out for what
> is ostensibly a generic data structure.
>

Agreed. I plan to rename all transport independent services svc_xprt_xxxx,
and move all transport independent services currently in svcsock.c to
svc_xprt.c.
 
>> The text transport name is contained in a field in the xprt structure.
>> A new service has been added as well to take a transport name
>> instead of an IP protocol number to specify the transport on which the
>> listening endpoint is to be created. This function is defined as follows:
>> 
>> int svc_create_svcsock(struct svc_serv, char *transport_name,
>>                        unsigned short port, int flags);
> 
> Again, "sock" should be sensibly excised from the function name.
> 
>> The existing svc_makesock interface was left to avoid impacts to existing
>> servers. It has been modified to map IP protocol numbers to transport
>> strings.
> 
> I think the client and server should use the *same* mechanism for
> matching transports -- either a string *or* a protocol number (not
> necessarily the IPPROTO number, but something mapped to it, so we can
> add transport types like RDMA that don't have an IPPROTO number already).
> 
> How do others feel about this?  String, or protocol number?

String.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

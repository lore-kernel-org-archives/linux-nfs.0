From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 13/35] svc: Change services to use new	svc_create_xprt service
Date: Thu, 04 Oct 2007 09:27:11 -0500
Message-ID: <1191508031.411.29.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192758.3250.2651.stgit@dell3.ogc.int>
	<608B3480-525A-43C6-945C-3482CDE823FC@oracle.com>
	<20071004023531.GV21388@sgi.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdRgk-0002m2-Dg
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 07:28:38 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IdRgo-000785-9y
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 07:28:35 -0700
In-Reply-To: <20071004023531.GV21388@sgi.com>
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

On Thu, 2007-10-04 at 12:35 +1000, Greg Banks wrote:
> On Tue, Oct 02, 2007 at 11:44:50AM -0400, Chuck Lever wrote:
> > On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
> > >
> > >-static int find_socket(struct svc_serv *serv, int proto)
> > >+static int find_xprt(struct svc_serv *serv, char *proto)
> > > {
> > > 	struct svc_sock *svsk;
> > > 	int found = 0;
> > > 	list_for_each_entry(svsk, &serv->sv_permsocks, sk_list)
> > >-		if (svsk->sk_sk->sk_protocol == proto) {
> > >+		if (strcmp(svsk->sk_xprt.xpt_class->xcl_name, proto) == 0) {
> > > 			found = 1;
> > > 			break;
> > > 		}
> > 
> > This is scary.  :-)
> > 
> > First, I think we would be better off making the server transport API  
> > stronger by not allowing ULPs to dig around in svc_xprt or the  
> > svc_xprt_class structures directly.  Perhaps you could provide a  
> > method for obtaining the transport's NETID.
> 
> Or a function to do the match:
> 
> struct svc_xprt_ops {
>     ...
>     int (*xpo_netid_supported)(const char *netid);
>     ...
> };
> 
> Or, your could push the find_xprt() function down into svc_xprt.c
> where such futzing belongs.

I think this is the correct approach, although the parameters of the
svc_find_xprt function may need some tweaking.

> 
> > Second, is there any guarantee that the string name of the underlying  
> > protocol 

The transport string doesn't name a protocol, it names a transport
class. I'll check the code because I bet I've got a confused name or two
in the code.

The transport class identifies a provider that serves up the API we've
defined. To be painfully pedantic, the transport provider determines the
underlying protocol. Within a protocol family, the address family in the
sockaddr is used to further discriminate. So in the case of the "tcp"
transport class, the socket type (SOCK_STREAM), combined with the
address family (AF_INET/AF_INET6) in the provided sockaddr determines
the protocol (TCP/IPV4, or TCP/IPV6). 

Along these lines, a reasonable argument could be made that the names of
the transport classes should be "sock_stream", and "sock_dgram", not
"tcp", and "udp". 

> is the same as the name of the transport class?  Is there  
> > any relationship between the transport name and the NETIDs it supports?
> 

I think trying to map the netid to a transport instance is a mistake.
The "transport" name here is above the network layer and maps more to an
API (socket, ofa rdma) than to a network protocol. "rdma" in this
context can mean iWARP, or IB, and iWARP can mean RDDP/TCP, RDDP/SCTP,
etc...

Given the current support, "rdma" can be over IB or RDDP/TCP. So, IMO:

rdma:AF_INET:0.0.0.0:2081
rdma:AF_INET6:ff.ff.ff.ff.10.10.0.5:2081
tcp:AF_INET:0.0.0.0:2049

etc, are strings that map a transport instance logically and uniquely.

If you always want to listen on zero, then you can get rid of the
address itself. 

This approach also allows the transport to extend naturally to other
address families. 

> This is already confused: our "tcp" transport supports both TCP/IPv4
> and TCP/IPv6, which are two separate netids "tcp4" and "tcp6" in
> TLI jargon.


> 
> Greg.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC] [PATCH] rpcbind netid declared per-transport
Date: Fri, 31 Aug 2007 12:41:20 -0400
Message-ID: <EXNANE01FlmmlQ080Gx00000245@exnane01.hq.netapp.com>
References: <EXNANE01Mb1s7nlT2Nq00000219@exnane01.hq.netapp.com>
	<46D820F8.6040309@oracle.com>
	<1188570399.6649.83.camel@heimdal.trondhjem.org>
	<46D825EB.90801@oracle.com>
	<1188573228.6649.100.camel@heimdal.trondhjem.org>
	<46D835F4.4030703@oracle.com>
	<EXNANE01hjJ8uT6Ssuo00000243@exnane01.hq.netapp.com>
	<46D84176.5020807@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR9ZA-0008GI-RZ
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 09:41:53 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IR9ZD-0000I9-9q
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 09:41:57 -0700
In-Reply-To: <46D84176.5020807@oracle.com>
References: <EXNANE01Mb1s7nlT2Nq00000219@exnane01.hq.netapp.com>
	<46D820F8.6040309@oracle.com>
	<1188570399.6649.83.camel@heimdal.trondhjem.org>
	<46D825EB.90801@oracle.com>
	<1188573228.6649.100.camel@heimdal.trondhjem.org>
	<46D835F4.4030703@oracle.com>
	<EXNANE01hjJ8uT6Ssuo00000243@exnane01.hq.netapp.com>
	<46D84176.5020807@oracle.com>
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

At 12:27 PM 8/31/2007, Chuck Lever wrote:
>Talpey, Thomas wrote:
>> "RPCB_" prefix: They're (with this patch) part of the rpcbind api. The prefix
>...
>It's a nit, I guess.

How about RPCBIND_NETID_foo? It's more obvious, and keeps the RPC...

>> RPCB_MAXNETIDLEN: Sure, I'll move it. It is, after all, a limit on the string
>>...
>
>We need to know the maximum size to compute the largest possible size of 
>the RPC buffer needed for the request.  See the definition of 
>RPCB_netid_sz.  Those are all added together to get the largest possible 
>request size, and that's used to compute the largest possible buffer size.

Yes, I know, but it could be larger and more dynamically calculated.
I'll move it, but leave it as-is then, there is no need to change it.
I'll also move the MAXADDRLEN, since that has the same meaning
for the UNIVERSAL_ADDR argument.


>Netids are standardized on-the-wire marshaled values, so they definitely 
>belong in msg_prot.h, which as you say, contains marshaling and error 
>code definitions.

XDR marshaling, a much lower level than rpcbind. But, I'll move the netid's.
It's a fine spot for them.

Stand by for updated patch.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

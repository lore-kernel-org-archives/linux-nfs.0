From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC,PATCH 00/20] svc: Server Side Transport Switch
Date: Thu, 30 Aug 2007 21:19:26 -0400
Message-ID: <EXNANE01tTXIqKgXTss0000020f@exnane01.hq.netapp.com>
References: <C2FB1E3A.3A83F%tom@opengridcomputing.com>
	<46D732D1.3070008@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQvCU-0006qA-Ip
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 18:21:30 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQvCX-0004Q4-W1
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 18:21:35 -0700
In-Reply-To: <46D732D1.3070008@oracle.com>
References: <C2FB1E3A.3A83F%tom@opengridcomputing.com>
	<46D732D1.3070008@oracle.com>
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

At 05:12 PM 8/30/2007, Chuck Lever wrote:
>Version 2 of the rpcbind protocol doesn't take a netid.  To register a 
>netid with the local portmapper, you need two things to happen:
>
>1.  The local portmapper needs to be something that can take v3 or v4 
>registration requests
>
>2.  rpcb_register needs to be converted to use v3 or v4 of the rpcbind 
>protocol to do the registering.
>
>3.  Mr. Talpey needs to submit his patch to make RPC transport 
>implementations support RPC_DISPLAY_NETID so the rpcbind client has a 
>proper netid string to send to the local rpcbind daemon.

You said "two" things. :-)

Yes, I'm working on the rpcbind path a bit. Hope to have some patches
to it and the xprt framework out for comments tomorrow, along with some
new NFS/RDMA code.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

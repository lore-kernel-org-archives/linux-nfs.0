From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC,PATCH 00/20] svc: Server Side Transport Switch
Date: Wed, 29 Aug 2007 13:01:01 -0400
Message-ID: <EXNANE01EjQxzmWecm9000001e6@exnane01.hq.netapp.com>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<46D5A3DE.8030208@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQQwm-0006GA-Q8
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:03:16 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQQwo-0003f0-1L
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:03:21 -0700
In-Reply-To: <46D5A3DE.8030208@oracle.com>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<46D5A3DE.8030208@oracle.com>
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

At 12:50 PM 8/29/2007, Chuck Lever wrote:
>I think the client and server should use the *same* mechanism for 
>matching transports -- either a string *or* a protocol number (not 
>necessarily the IPPROTO number, but something mapped to it, so we can 
>add transport types like RDMA that don't have an IPPROTO number already).
>
>How do others feel about this?  String, or protocol number?

I think the string is the better approach, because it's self-describing
and maps nicely to the transport. Integers are more like the existing
code, however, and (very) easy to deal with.

At the moment, my code implements the integer method and it's
relatively clean, except for one thing. In nfs_show_mount_options()
(fs/nfs/super.c), the kernel attempts to print the mount options'
proto= setting based on the naked IPPROTO. This fails for rdma.
With a string, all it would have to do is copy the string.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

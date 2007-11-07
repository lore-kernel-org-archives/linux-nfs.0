From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/7] SUNRPC: Fix TCP rebinding logic
Date: Wed, 07 Nov 2007 18:47:10 -0500
Message-ID: <1194479230.7735.0.camel@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003945.13713.61995.stgit@heimdal.trondhjem.org>
	<473240BE.7000709@oracle.com>
	<1194476901.7504.66.camel@heimdal.trondhjem.org>
	<47324A12.9080201@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpuaY-0006g4-LT
	for nfs@lists.sourceforge.net; Wed, 07 Nov 2007 15:45:38 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ipuae-0003li-8w
	for nfs@lists.sourceforge.net; Wed, 07 Nov 2007 15:45:44 -0800
In-Reply-To: <47324A12.9080201@oracle.com>
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


On Wed, 2007-11-07 at 18:28 -0500, Chuck Lever wrote:
> > We've always had to deal with breaking out of the loops. If we don't, we
> > will deadlock the computer.
> 
> In that case it might make sense to allow some scheduling between each 
> socket bind attempt, and do only a single pass over the port range 
> before breaking out.  Then you could forget about whether the range 
> changes -- you will use the new range the next time a connection is 
> attempted.

No. We shouldn't ever schedule from an rpciod process context.

Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

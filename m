From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 3/7] SUNRPC: Allow the client to detect if the TCP
 connection	is closed
Date: Fri, 09 Nov 2007 10:25:20 -0500
Message-ID: <EXNANE01CIFoPkG0rm300000904@exnane01.hq.netapp.com>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003950.13713.24126.stgit@heimdal.trondhjem.org>
	<EXNANE01OMyQlmLFQG100000900@exnane01.hq.netapp.com>
	<1194618806.7459.44.camel@heimdal.trondhjem.org>
	<EXNANE01prR0E6faZWZ00000903@exnane01.hq.netapp.com>
	<1194619730.7459.48.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, Chuck Lever <Chuck.Lever@oracle.com>,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IqVjX-0004da-3Y
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 07:25:23 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IqVjc-0001xe-Gm
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 07:25:28 -0800
In-Reply-To: <1194619730.7459.48.camel@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003950.13713.24126.stgit@heimdal.trondhjem.org>
	<EXNANE01OMyQlmLFQG100000900@exnane01.hq.netapp.com>
	<1194618806.7459.44.camel@heimdal.trondhjem.org>
	<EXNANE01prR0E6faZWZ00000903@exnane01.hq.netapp.com>
	<1194619730.7459.48.camel@heimdal.trondhjem.org>
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

At 09:48 AM 11/9/2007, Trond Myklebust wrote:
>
>On Fri, 2007-11-09 at 09:35 -0500, Talpey, Thomas wrote:
>> I guess I return to my question - why not just set the XPRT bits when
>> we decided to close? Why wait for TCP to click through to this state?
>> It doesn't guarantee anything on the server until we see an ACK.
>
>We could do that, but IMO it is cleaner to keep all of this
>state-dependent code in one place.

I'm fine with that.

> The state change occurs while we're
>inside the call to ->shutdown(), so there is no delay.

I don't think so, in the case that the network is disconnected and
there is some data pending in the TCP output queue. The FIN won't
be sent until the window advances to allow it, and this could happen
much later. In the meantime, the xprt isn't even marked CLOSING.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

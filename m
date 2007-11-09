From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/7] SUNRPC: Allow the client to detect if the	TCP
	connection	is closed
Date: Fri, 09 Nov 2007 12:37:19 -0500
Message-ID: <1194629839.7459.61.camel@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003950.13713.24126.stgit@heimdal.trondhjem.org>
	<EXNANE01OMyQlmLFQG100000900@exnane01.hq.netapp.com>
	<1194618806.7459.44.camel@heimdal.trondhjem.org>
	<EXNANE01prR0E6faZWZ00000903@exnane01.hq.netapp.com>
	<1194619730.7459.48.camel@heimdal.trondhjem.org>
	<EXNANE01CIFoPkG0rm300000904@exnane01.hq.netapp.com>
	<1194622369.7459.52.camel@heimdal.trondhjem.org>
	<EXNANE01rxUn3AkTR6000000905@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Chuck Lever <Chuck.Lever@oracle.com>,
	nfsv4@linux-nfs.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IqXl6-00058C-Am
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 09:35:09 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IqXlC-0004mh-24
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 09:35:14 -0800
In-Reply-To: <EXNANE01rxUn3AkTR6000000905@exnane01.hq.netapp.com>
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


On Fri, 2007-11-09 at 11:53 -0500, Talpey, Thomas wrote:
> At 10:32 AM 11/9/2007, Trond Myklebust wrote:
> >
> >On Fri, 2007-11-09 at 10:25 -0500, Talpey, Thomas wrote:
> >> At 09:48 AM 11/9/2007, Trond Myklebust wrote:
> >> > The state change occurs while we're
> >> >inside the call to ->shutdown(), so there is no delay.
> >> 
> >> I don't think so, in the case that the network is disconnected and
> >> there is some data pending in the TCP output queue. The FIN won't
> >> be sent until the window advances to allow it, and this could happen
> >> much later. In the meantime, the xprt isn't even marked CLOSING.
> >
> >Oh, I see what you mean. So, correction: the TCP_FIN_WAIT1 state means
> >that the FIN has been _queued_ by the TCP layer. It may or may not have
> >hit the wire yet.
> 
> Correct. And even if were sent, the FINWAIT1 state does not mean the
> peer has transitioned. You need to see the ACK (which often comes in
> the same packet as the peer's FIN).

That is really of no direct concern to the RPC client. The important
thing for us is to clear the XPRT_CONNECTED flag in order to indicate
that the socket will no longer accept further requests, and we want to
set XPRT_CLOSING in order to tell anybody who tries to reconnect that
they need to wait.

>  All this is a gawd-awful layering violation, you know. :-)

I disagree. This is exactly the same thing as using poll() to monitor
the state of the socket in userland.

Cheers
  Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

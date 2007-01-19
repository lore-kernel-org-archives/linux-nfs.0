From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 14/14] SUNRPC: Debugging aid
Date: Fri, 19 Jan 2007 17:28:40 -0500
Message-ID: <1169245720.6262.27.camel@lade.trondhjem.org>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233100.23310.25683.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H82ED-00027r-PV
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 14:29:00 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19MRednepzMbCi8EwS8+PlypSzfpCfgHvU=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H82EE-0005u1-35
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 14:28:59 -0800
To: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20070118233100.23310.25683.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-01-18 at 18:31 -0500, Chuck Lever wrote:
> Add helper functions for tracking the current FSM state for each RPC task.
> The FSM state name is now displayed in rpc_show_task instead of the
> absolute address of the FSM function.
> 

Urgh. When are we ever going to need this information?

We already have the tk_action pointer and the rpc_queue. This doesn't
provide us with any more information.

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

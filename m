From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 15/19] RPCRDMA: Kconfig and header
	file	with	rpcrdma protocol definitions
Date: Thu, 20 Sep 2007 17:13:04 -0400
Message-ID: <1190322784.6763.147.camel@heimdal.trondhjem.org>
References: <EXNANE013MBhe3WYIgo000004be@exnane01.hq.netapp.com>
	<1190321705.6763.140.camel@heimdal.trondhjem.org>
	<EXNANE01Uor03u9PH3I00000571@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYTLH-0001cM-QS
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 14:13:48 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IYTLK-0002C8-Bz
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 14:13:52 -0700
In-Reply-To: <EXNANE01Uor03u9PH3I00000571@exnane01.hq.netapp.com>
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

On Thu, 2007-09-20 at 17:03 -0400, Talpey, Thomas wrote:
> At 04:55 PM 9/20/2007, Trond Myklebust wrote:
> >On Mon, 2007-09-10 at 13:49 -0400, Talpey, Thomas wrote:
> >
> >> +config SUNRPC_XPRT_RDMA
> >> +	tristate "RDMA transport for sunrpc (EXPERIMENTAL)"
> >> +	depends on SUNRPC && EXPERIMENTAL
> >> +	default m
> >> +	help
> >> +	  Adds a client RPC transport for supporting kernel NFS over RDMA
> >> +	  mounts, including Infiniband and iWARP. Experimental.
> >> +
> >
> >Hmm... There is a dependency on the Infiniband code that is missing
> >here. I'm getting the following compile errors:
> 
> Ah - yes, you must have Infiniband or iWARP configured.
> 
> Actually, I think the fix is maybe a "select INFINIBAND".
> Similar to the way NFS_FS select's SUNRPC. Will correct
> this in either case.

Please send it as an incremental patch.

Note, however, that automatically selecting INFINIBAND is never going to
suffice to make RDMA work: the user needs to configure the correct
hardware support too.
That makes me tend to prefer making it a 'depends on'...

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

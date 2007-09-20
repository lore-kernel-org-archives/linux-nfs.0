From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 15/19] RPCRDMA: Kconfig and header file
 with	rpcrdma protocol definitions
Date: Thu, 20 Sep 2007 17:03:36 -0400
Message-ID: <EXNANE01Uor03u9PH3I00000571@exnane01.hq.netapp.com>
References: <EXNANE013MBhe3WYIgo000004be@exnane01.hq.netapp.com>
	<1190321705.6763.140.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYTCi-0000ho-89
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 14:04:56 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IYTCl-00066m-Q3
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 14:05:01 -0700
In-Reply-To: <1190321705.6763.140.camel@heimdal.trondhjem.org>
References: <EXNANE013MBhe3WYIgo000004be@exnane01.hq.netapp.com>
	<1190321705.6763.140.camel@heimdal.trondhjem.org>
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

At 04:55 PM 9/20/2007, Trond Myklebust wrote:
>On Mon, 2007-09-10 at 13:49 -0400, Talpey, Thomas wrote:
>
>> +config SUNRPC_XPRT_RDMA
>> +	tristate "RDMA transport for sunrpc (EXPERIMENTAL)"
>> +	depends on SUNRPC && EXPERIMENTAL
>> +	default m
>> +	help
>> +	  Adds a client RPC transport for supporting kernel NFS over RDMA
>> +	  mounts, including Infiniband and iWARP. Experimental.
>> +
>
>Hmm... There is a dependency on the Infiniband code that is missing
>here. I'm getting the following compile errors:

Ah - yes, you must have Infiniband or iWARP configured.

Actually, I think the fix is maybe a "select INFINIBAND".
Similar to the way NFS_FS select's SUNRPC. Will correct
this in either case.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

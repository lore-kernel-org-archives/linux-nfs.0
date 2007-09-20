From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 15/19] RPCRDMA: Kconfig and header file
 with	rpcrdma protocol definitions
Date: Thu, 20 Sep 2007 17:18:36 -0400
Message-ID: <EXNANE01qSkcJse1fTv00000573@exnane01.hq.netapp.com>
References: <EXNANE013MBhe3WYIgo000004be@exnane01.hq.netapp.com>
	<1190321705.6763.140.camel@heimdal.trondhjem.org>
	<EXNANE01Uor03u9PH3I00000571@exnane01.hq.netapp.com>
	<1190322784.6763.147.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYTQA-0002Ac-Ay
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 14:18:50 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IYTQD-0004es-Uh
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 14:18:55 -0700
In-Reply-To: <1190322784.6763.147.camel@heimdal.trondhjem.org>
References: <EXNANE013MBhe3WYIgo000004be@exnane01.hq.netapp.com>
	<1190321705.6763.140.camel@heimdal.trondhjem.org>
	<EXNANE01Uor03u9PH3I00000571@exnane01.hq.netapp.com>
	<1190322784.6763.147.camel@heimdal.trondhjem.org>
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

At 05:13 PM 9/20/2007, Trond Myklebust wrote:
>Please send it as an incremental patch.

Will do - have to wait for later unfortunately.

>Note, however, that automatically selecting INFINIBAND is never going to
>suffice to make RDMA work: the user needs to configure the correct
>hardware support too.
>That makes me tend to prefer making it a 'depends on'...

One reason to prefer "select" is that the option will disappear if
it "depends on" and INFINIBAND isn't turned on. That's not the
way RPC over sockets transports is visible. For example, if TCP is
off you still get SUNRPC.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

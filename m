From: Olaf Kirch <okir@suse.de>
Subject: Re: Bug in nfs client handling of EJUKEBOX
Date: Fri, 25 Feb 2005 10:29:59 +0100
Message-ID: <20050225092959.GE15249@suse.de>
References: <1109101592/oystr@hugh.cs.washington.edu> <20050224115531.GF11336@suse.de> <1109275373.11433.59.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Sanislo <oystr@cs.washington.edu>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4bnm-0002Ho-TJ
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 01:30:26 -0800
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D4bnT-0007CI-19
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 01:30:26 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1109275373.11433.59.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Feb 24, 2005 at 12:02:53PM -0800, Trond Myklebust wrote:
> I'm thinking it might make sense to move that code into rpc_delete_timer
> itself, and perhaps change the condition to "!RPC_IS_QUEUED(task)", so
> that we test if the task is queued on a waitqueue, rather than if it is
> still running.
> 
> How about the following?

Fine with me.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

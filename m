From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] 1/3 - RPC metrics support
Date: Fri, 02 Apr 2004 12:33:03 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <406CD0DF.26DA81A0@melbourne.sgi.com>
References: <482A3FA0050D21419C269D13989C611302B07BF6@lavender-fe.eng.netapp.com>
		 <20040401235803.GA9409@sgi.com> <1080866042.10521.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Charles Lever <Charles.Lever@netapp.com>,
        Jeremy McNicoll <jeremy@mcnicoll.ca>,
        Patrick Mochel <mochel@digitalimplant.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9EUg-0002oQ-TF
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 18:33:18 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9EUg-0007x4-Ig
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 18:33:18 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

Trond Myklebust wrote:
> 
> On Thu, 2004-04-01 at 18:58, Greg Banks wrote:
> 
> > struct rpc_metric_totals {
> >       u64 mt_ops;         /* count of operations */
> 
> Let's not go there... 64-bit arithmetic on a 32-bit platform is still
> not one of gcc's strong points, 

This is of course not something I considered ;-)

> so let's not force everything into one
> mold simply in order to save a couple of lines of code. Performance does
> matter too...

Fair enough.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

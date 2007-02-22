From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: poor nfs performance & hangs with latest kernels
Date: Thu, 22 Feb 2007 15:34:57 -0500
Message-ID: <1172176497.6382.6.camel@heimdal.trondhjem.org>
References: <45D9B915.2010305@hq.vsaa.lv>
	<17882.49990.799201.335846@notabene.brown> <45DC4BB3.7090706@imag.fr>
	<17884.65504.902843.745554@notabene.brown>
	<1172173328.18921.13.camel@hoeplx2923>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs <nfs@lists.sourceforge.net>
To: Norman Weathers <norman.r.weathers@conocophillips.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HKKeo-0007aV-Tg
	for nfs@lists.sourceforge.net; Thu, 22 Feb 2007 12:35:15 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18tcGxQowl5L+xLcEEmJRd3sbeIMSra410=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HKKen-00022Q-CD
	for nfs@lists.sourceforge.net; Thu, 22 Feb 2007 12:35:17 -0800
In-Reply-To: <1172173328.18921.13.camel@hoeplx2923>
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

On Thu, 2007-02-22 at 13:42 -0600, Norman Weathers wrote:
> Neil,
> 
> I don't remember if I responded when you guys sent out the patch
> originally.  It indeed helps the rewrite situation quite a bit with the
> 2.6.20 kernel.  Hopefully, it will help Jean-Noel's problem as well.
> Thanks for getting that pushed through.
> 
> There is another issue, and I am not for sure where it is related.
> About 18 months ago, we did some performance testing with our cluster
> nodes, and noticed very good performance using iozone (good performance
> meaning we had ~ 170 MB/s writes, even better for the rewrite mode, and
> off the chart with read, due to caching of course).  Now, after a couple
> of updates, we have noticed that our writes and reads are about the
> same, but our rewrites using iozone are sometimes 1/2 of the performance
> of the writes.  Also, during that time, the load average (10 nodes,
> gigabit connected, server bonded dual gigabit to our core switch) is
> anywhere from 15 to 32, and as it gets higher (closer to the 32), it can
> cause the server to be really slow.  During this time, the disk io wait
> is high, but processor load is low.  We have <>updated<> our clients
> from an older 2.6.12.1 to a 2.6.14-ck1 patch, and the servers from a
> 2.6.11.7 to 2.6.14-ck1 as well.  Has there been some big changes in the
> way clients or servers are requesting write information during an iozone
> rewrite possibly.  If I truncate the file and rewrite from scratch, I
> can almost always get the > 170 MB/s on the wire to my boxes...
> 
> So, the patch does now allow the iozones to complete, but there is still
> a high load on the boxes.
> 
> Any testing or other information I can get that will help, please let me
> know.
> 
> Pertinent Information:
> 64 bit servers and clients
> FC3 and FC4 on the clients using 2.6.14 and later kernels
> FC3 and FC6 on the servers using 2.6.14 and later kernels
> All hosts are gigabit ethernet with the servers connected directly to
> our core switches, and clients connected to gigabit edge switches that
> are quad trunked back to the core (~ 64 nodes on the edge switch, but
> all nodes are idle during the test).
> 
> Norman Weathers

I'm confused. Are you seeing this with a stock 2.6.20 kernel, or only
the older kernels?

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

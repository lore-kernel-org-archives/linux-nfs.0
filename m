From: Greg Banks <gnb@sgi.com>
Subject: Re: Performance udp vs. tcp
Date: Mon, 23 Aug 2004 20:36:37 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040823103637.GK10775@sgi.com>
References: <4129BF94.20902@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BzCC1-00010t-Kt
	for nfs@lists.sourceforge.net; Mon, 23 Aug 2004 03:36:49 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BzCC0-0002gA-5S
	for nfs@lists.sourceforge.net; Mon, 23 Aug 2004 03:36:49 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <4129BF94.20902@bio.ifi.lmu.de>
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

On Mon, Aug 23, 2004 at 11:57:40AM +0200, Frank Steiner wrote:
> Hi,
> 
> I just ran some bonnie++ tests to measure the nfs performance of udp vs.
> tcp, expecting tcp to be better (after reading this list and some 
> newsgroups).
> Amazingly, it turned out that udp with rsize/wsize 16k was the best, taking
> the average over all tests. tcp was a little better in some of the 
> large-file
> tests, but especially with creating/stating/deleting 16 thousands of small
> file, sequentially and randomly, udp was better than tcp in every test
> (between 5-15 % faster). I rann all the tests also with differenct tcp 
> windows
> sizes, and a larger window size speeded up udp and tcp more or less in the
> same way.

With a metadata-heavy workload like this the [rw]size makes little
difference.

> I was very amazed by this, but I guess this could be caused by our network,
> which is a fully switched "100mbit for client/1gbit for servers" network,
> so we have almost no packet loss.
> 
> If I got the discussions on the list and in the newsgroups right, on a
> lossy network udp would slow down due to the packet loss and resends.
> 
> So, can my result be correct for a really fast and stable network? Or is
> it some "bonnie++ likes udp" effect? :-)

There's nothing unusual here.  On a low-latency uncongested unlossy
network, it's not surprising that UDP is faster.  As soon as any
of those factors goes away, TCP starts winning.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

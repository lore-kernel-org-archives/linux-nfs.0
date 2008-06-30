From: Jeff Layton <jlayton@redhat.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Mon, 30 Jun 2008 11:26:54 -0400
Message-ID: <20080630112654.012ce3e4@barsoom.rdu.redhat.com>
References: <48652C24.6030409@gmail.com>
	<OF20F6A497.A6F52D0F-ON65257478.00377AB6-65257478.0037E4AE@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Dean Hildebrand <seattleplus@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Benny Halevy <bhalevy@panasas.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, Peter Staubach <staubach@redhat.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36366 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761602AbYF3P2j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jun 2008 11:28:39 -0400
In-Reply-To: <OF20F6A497.A6F52D0F-ON65257478.00377AB6-65257478.0037E4AE@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Jun 2008 15:40:30 +0530
Krishna Kumar2 <krkumar2@in.ibm.com> wrote:

> Dean Hildebrand <seattleplus@gmail.com> wrote on 06/27/2008 11:36:28 PM:
> 
> > One option might be to try using O_DIRECT if you are worried about
> > memory (although I would read/write in at least 1 MB at a time).  I
> > would expect this to help at least a bit especially on reads.
> >
> > Also, check all the standard nfs tuning stuff, #nfsds, #rpc slots.
> > Since with a loopback you effectively have no latency, you would want to
> > ensure that neither the #nfsds or #rpc slots is a bottleneck (if either
> > one is too low, you will have a problem).  One way to reduce the # of
> > requests and therefore require fewer nfsds/rpc_slots is to 'cat
> > /proc/mounts' to see your wsize/rsize.  Ensure your wsize/rsize is a
> > decent size (~ 1MB).
> 
> Number of nfsd: 64, and
>       sunrpc.transports = sunrpc.udp_slot_table_entries = 128
>       sunrpc.tcp_slot_table_entries = 128
> 
> I am using:
> 
>       mount -o
> rw,bg,hard,nointr,proto=tcp,vers=3,rsize=65536,wsize=65536,timeo=600,noatime
>  localhost:/local /nfs
> 
> I have also tried with 1MB for both rsize/wsize and it didn't change the BW
> (other than
> mini variations).
> 
> thanks,
> 
> - KK
> 

Recently I spent some time with others here at Red Hat looking
at problems with nfs server performance. One thing we found was that
there are some problems with multiple nfsd's. It seems like the I/O
scheduling or something is fooled by the fact that sequential write
calls are often handled by different nfsd's. This can negatively
impact performance (I don't think we've tracked this down completely
yet, however).

Since you're just doing some single-threaded testing on the client
side, it might be interesting to try running a single nfsd and testing
performance with that. It might provide an interesting data point.

Some other thoughts of things to try:

1) run the tests against an exported tmpfs filesystem to eliminate
underlying disk performance as a factor.

2) test nfsv4 -- nfsd opens and closes the file for each read/write.
nfsv4 is statelful, however, so I don't believe it does that there.

As others have pointed out though, testing with client and server on
the same machine is not necessarily eliminating performance
bottlenecks. You may want to test with dedicated clients and servers
(maybe on a nice fast network or with a gigE crossover cable or
something).

-- 
Jeff Layton <jlayton@redhat.com>

From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Thu, 26 Feb 2004 15:50:51 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040226145051.GE32597@suse.de>
References: <Pine.LNX.4.44.0402261415410.24606-100000@kenzo.iwr.uni-heidelberg.de> <32952.207.214.87.84.1077802844.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>,
	Greg Banks <gnb@melbourne.sgi.com>, ShantanuGoel <sgoel01@yahoo.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwMum-0001JN-Qz
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 06:55:04 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AwMf3-0001f2-VR
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 06:38:50 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <32952.207.214.87.84.1077802844.squirrel@webmail.uio.no>
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

On Thu, Feb 26, 2004 at 02:40:44PM +0100, Trond Myklebust wrote:
> To simply assert that "async" is somehow equivalent to "not important" is
> just plain wrong.

Agreed, and I also agree that my suggestion of always preferring sync
tasks over async tasks is simplistic. But I think the patch proposed
by Shantanu adds more complexity to an already overly complex rpc
implementation.

The general "unfairness" observed in writes is due to the fact that we
allow a writing process to dirty a large number of pages without blocking
for the actual IO. So if you write a large file, nfs_flushd can easily
saturate the transport (which is a good thing for performance) but it's
bad for sync tasks.

One problem is that currently, there seems to be no upper bound at all
on the number of write requests we schedule. So one step in the right
direction may be to check the number of backlogged tasks and refrain
from scheduling more write requests if it exceeds a certain threshold.

Applications doing lots of stats etc are punished so severely because
all these operations are synchronous.  So if you have a maximum backlog
of N RPC requests, your average delay per sync rpc operation is O(N).

So I think it could help if nfs_flushd and friends check the transport
backlog before scheduling new writes. There should be tunables for
the minimum number of pending writes we're always permitted to
schedule, and a maximum backlog length.

To avoid any ugliness related to layering violations, you could use
"color" to tag different RPC requests rather than referring to "writes".

Of course, that's just changing the queuing, not real scheduling.
But that can be an advantage, too, because it keeps things relatively
simple.

BTW I think reading is much less of a problem. The number of readaheads
scheduled by generic_file_read is limited, so it's entirely different
from the "lets blow the router's fuse" approach of the NFS write code.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

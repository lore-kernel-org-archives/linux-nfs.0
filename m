From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: [PATCH] Smooth out NFS client writeback
Date: Wed, 29 Jun 2005 08:35:32 -0700
Message-ID: <482A3FA0050D21419C269D13989C611307CF4CE7@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Shantanu Goel" <sgoel01@yahoo.com>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DnebD-0004xi-G8
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 08:35:39 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DnebD-0002Jx-CW
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 08:35:39 -0700
To: "Peter Staubach" <staubach@redhat.com>
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

> I don't think that there will be more over the wire=20
> operations generated
> when using the range versus always specifying the entire=20
> file.

committing the whole file at once is simply more efficient from a
network perspective when an application is performing random writes
(unless it is using O_SYNC).  there are some cases where it won't make a
difference whether a range or a whole file commit is used, but i think
it would be really hard to figure out a client-side heuristic to decide
which is better.

> I would claim that a client,
> which simply issues a blanket COMMIT(0,0), without already=20
> having gathered
> up the buffers/pages/whatever that need committing, is=20
> broken.  It will be
> unsafe because it will be subject to races like more data=20
> getting written
> with UNSTABLE while the COMMIT is happening.  This new data=20
> may or may not
> have been committed by the COMMIT.

the linux client already keeps track of the order of writes and commits
well enough that this isn't an issue.

> Bottom line for me -- if the client can do something to help=20
> the server to
> help the client and it is an overall win, then I think that=20
> it should do so...

we're talking about potentially adding complexity to the client and
increasing the number of write and commit operations on the wire, which
could have a negative performance impact in other environments (think
WAN).  all this to optimize a particular workload against a particular
server implementation.

i'm not saying this type of work shouldn't be explored, but as we
consider the change, we should be very careful especially since we don't
have adequate performance regression test coverage yet.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

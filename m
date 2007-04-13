From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Merge plans for RPC/RDMA? (Was: Re: [PATCH 000 of
	14]	knfsd: Preparation for IPv6 support in NFS server.)
Date: Fri, 13 Apr 2007 18:14:25 -0400
Message-ID: <1176502465.6394.26.camel@heimdal.trondhjem.org>
References: <170fa0d20704131347u4a28b5d1h1959227980449fbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, NeilBrown <neilb@suse.de>,
	Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Mike Snitzer <snitzer@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcU2Z-00047r-IY
	for nfs@lists.sourceforge.net; Fri, 13 Apr 2007 15:14:47 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX180Yq9mKbOySeRLU+J67G8GtSUNsfKYCuI=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HcU2b-0003Qp-Mg
	for nfs@lists.sourceforge.net; Fri, 13 Apr 2007 15:14:50 -0700
In-Reply-To: <170fa0d20704131347u4a28b5d1h1959227980449fbf@mail.gmail.com>
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

On Fri, 2007-04-13 at 16:47 -0400, Mike Snitzer wrote:
> I must be missing something because I don't see _any_ trace of the
> core RPC over RDMA support (xprtrdma et al), your RPC Transport
> Switch, or any of the other supporting changes in mainline.  Could
> you, or others, please clarify the plan for merging RPC/RDMA?

That would be a question for the actual RPC/RDMA developers (i.e. James
Lentini and Tom Talpey). They haven't submitted any code for review yet.


> Do you mean the NFS/RDMA server code from Tom Tucker of Open Grid
> Computing?  Why wouldn't this code be included?

That too has never been submitted for review AFAIK. Why would we include
it?

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

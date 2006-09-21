From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: cel's patches for 2.6.18 kernels
Date: Thu, 21 Sep 2006 11:06:16 -0400
Message-ID: <1158851176.5441.17.camel@lade.trondhjem.org>
References: <76bd70e30609201128r9188a17i51b779c6e1b569fc@mail.gmail.com>
	<20060920202010.GA22954@infradead.org>
	<76bd70e30609201353l7d8c063fp94916c509b08b24e@mail.gmail.com>
	<1158787006.5639.19.camel@lade.trondhjem.org>
	<76bd70e30609201929s1e01b453ia694774d77f9474c@mail.gmail.com>
	<451284E4.4050806@RedHat.com>
	<1158846435.7626.7.camel@lade.trondhjem.org>
	<76bd70e30609210750s5c8b943cg267513c64dc0433f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GQQ8N-0007FE-NN
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 08:06:40 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GQQ8N-0005HR-1k
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 08:06:40 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30609210750s5c8b943cg267513c64dc0433f@mail.gmail.com>
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

On Thu, 2006-09-21 at 10:50 -0400, Chuck Lever wrote:
> On 9/21/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> The current behavior is that the VM dumps a boat load of writes on the
> NFS client, and they all queue up on the RPC client's backlog queue.
> In the new code, each request is allowed to proceed further to the
> allocation of an RPC buffer before it is stopped.  The buffers come
> out of a slab cache, so low-memory behavior should be fairly
> reasonable.

What properties of slabs make them immune to low-memory issues?

> The small slot table size already throttles write-intensive workloads
> and anything that tries to drive concurrent I/O.  To add an additional
> constraint that multiple mount point go through a small fixed size
> slot table seems like poor design.

Its main purpose is precisely that of _limiting_ the amount of RPC
buffer usage, and hence avoiding yet another potential source of memory
deadlocks.
There is already a mechanism in place for allowing the user to fiddle
with the limits, 

> Perhaps we can add a per-mount point concurrency limit instead of a
> per-transport limit?

Why? What workloads are currently showing performance problems related
to this issue?



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

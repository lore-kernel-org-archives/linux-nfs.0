From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 010 of 11] knfsd: make rpc threads pools numa aware
Date: Mon, 07 Aug 2006 21:25:09 +1000
Message-ID: <1154949908.29877.130.camel@hole.melbourne.sgi.com>
References: <20060731103458.29040.patches@notabene>
	<1060731004234.29291@suse.de> <20060806024703.2fb9f307.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GA3EY-0000Ig-3Y
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 04:25:22 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GA3EX-0007wT-82
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 04:25:22 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060806024703.2fb9f307.akpm@osdl.org>
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

On Sun, 2006-08-06 at 19:47, Andrew Morton wrote:
> On Mon, 31 Jul 2006 10:42:34 +1000
> NeilBrown <neilb@suse.de> wrote:
> 
> > knfsd: Actually implement multiple pools.  On NUMA machines, allocate
> > a svc_pool per NUMA node; on SMP a svc_pool per CPU; otherwise a single
> > global pool.  Enqueue sockets on the svc_pool corresponding to the CPU
> > on which the socket bh is run (i.e. the NIC interrupt CPU).  Threads
> > have their cpu mask set to limit them to the CPUs in the svc_pool that
> > owns them.
> > 
> > This is the patch that allows an Altix to scale NFS traffic linearly
> > beyond 4 CPUs and 4 NICs.
> > 
> > Incorporates changes and feedback from Neil Brown, Trond Myklebust,
> > and Christoph Hellwig.
> 
> This makes the NFS client go BUG.  Simple nfsv3 workload (ie: mount, read
> stuff).  Uniproc, FC5.  
> 
> +	BUG_ON(m->mode == SVC_POOL_NONE);
> 

Reproduced on RHAS4; this patch fixes it for me.
--

knfsd: Fix a regression on an NFS client where mounting an
NFS filesystem trips a spurious BUG_ON() in the server code.
Tested using cthon04 lock tests on RHAS4-U2 userspace.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 net/sunrpc/svc.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletion(-)

Index: linux-2.6.18-rc2/net/sunrpc/svc.c
===================================================================
--- linux-2.6.18-rc2.orig/net/sunrpc/svc.c
+++ linux-2.6.18-rc2/net/sunrpc/svc.c
@@ -211,6 +211,11 @@ svc_pool_map_set_cpumask(unsigned int pi
 	struct svc_pool_map *m = &svc_pool_map;
 	unsigned int node; /* or cpu */
 
+	/*
+	 * The caller checks for sv_nrpools > 1, which
+	 * implies that we've been initialized and the
+	 * map mode is not NONE.
+	 */
 	BUG_ON(m->mode == SVC_POOL_NONE);
 
 	switch (m->mode)
@@ -241,7 +246,11 @@ svc_pool_for_cpu(struct svc_serv *serv, 
 	struct svc_pool_map *m = &svc_pool_map;
 	unsigned int pidx = 0;
 
-	BUG_ON(m->mode == SVC_POOL_NONE);
+	/*
+	 * SVC_POOL_NONE happens in a pure client when
+	 * lockd is brought up, so silently treat it the
+	 * same as SVC_POOL_GLOBAL.
+	 */
 
 	switch (m->mode) {
 	case SVC_POOL_PERCPU:





Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

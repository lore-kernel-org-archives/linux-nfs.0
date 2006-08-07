From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 010 of 11] knfsd: make rpc threads pools numa aware
Date: Mon, 07 Aug 2006 13:16:53 +1000
Message-ID: <1154920613.29877.85.camel@hole.melbourne.sgi.com>
References: <20060731103458.29040.patches@notabene>
	<1060731004234.29291@suse.de> <20060806024703.2fb9f307.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9vby-00039b-SD
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 20:17:02 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G9vby-0000VZ-Vf
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 20:17:03 -0700
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

Aha, I see what I b0rked up.  On the client, lockd starts an RPC
service via the old svc_create() interface, which avoids calling
svc_pool_map_init().  When the first NLM callback arrives,
svc_sock_enqueue() calls svc_pool_for_cpu() which BUGs out because
the map is not initialised.  The BUG_ON() was introduced in one
of the rewrites in response to review feedback in the last few
days; previously the code was simpler and would trivially return
pool 0, which is the right thing to do in this case.  The bug was
hidden on my test machines because they have SLES userspaces,
where lockd is broken because both the kernel and userspace think
the other one is doing the rpc.statd functionality.

A simple patch should fix this, coming up as soon as I can find
a non-SLES machine and run some client tests.

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

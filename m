From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 010 of 11] knfsd: make rpc threads pools numa	aware
Date: Mon, 31 Jul 2006 14:42:38 +1000
Message-ID: <1154320957.21040.1836.camel@hole.melbourne.sgi.com>
References: <20060731103458.29040.patches@notabene>
	<1060731004234.29291@suse.de> <20060730211454.ccf803f3.akpm@osdl.org>
	<17613.35001.745409.144623@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7Pc9-0006Jh-EM
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:42:49 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7Pc8-0000LE-OM
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:42:50 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17613.35001.745409.144623@cse.unsw.edu.au>
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

On Mon, 2006-07-31 at 14:36, Neil Brown wrote:
> On Sunday July 30, akpm@osdl.org wrote:
> > On Mon, 31 Jul 2006 10:42:34 +1000
> > NeilBrown <neilb@suse.de> wrote:
> > 
> > > +static int
> > > +svc_pool_map_init_percpu(struct svc_pool_map *m)
> > > +{
> > > +	unsigned int maxpools = num_possible_cpus();
> > > +	unsigned int pidx = 0;
> > > +	unsigned int cpu;
> > > +	int err;
> > > +
> > > +	err = svc_pool_map_alloc_arrays(m, maxpools);
> > > +	if (err)
> > > +		return err;
> > > +
> > > +	for_each_online_cpu(cpu) {
> > > +		BUG_ON(pidx > maxpools);
> > > +		m->to_pool[cpu] = pidx;
> > > +		m->pool_to[pidx] = cpu;
> > > +		pidx++;
> > > +	}
> > 
> > That isn't right - it assumes that cpu_possible_map is not sparse.  If it
> > is sparse, we allocate undersized pools and then overindex them.
> 
> I don't think so.
> 
> At this point we are largely counting the number of online cpus
> (in pidx (pool index) - this is returned). The two-way mapping
> to_pool and pool_to provides a mapping between the possible-sparse cpu
> list and a dense list of pool indexes.
> 
> If further cpus come on line they will be automatically included in
> pool-0. (as to_pool[n] will still be zero).
> 
> Does that make it at all clearer?

Umm, I think Andrew's right, num_possible_cpus() should be NR_CPUS.
If there's a value of `cpu' > num_possible_cpus(), which would happen
if the cpu numbers weren't contiguous, then m->to_pool[] will be
overflowed.  My bad, I didn't even consider the case of non-contiguous
CPU numbers and none of the machines available for testing had that
property.


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

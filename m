From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 010 of 11] knfsd: make rpc threads pools numa aware
Date: Mon, 31 Jul 2006 14:36:09 +1000
Message-ID: <17613.35001.745409.144623@cse.unsw.edu.au>
References: <20060731103458.29040.patches@notabene>
	<1060731004234.29291@suse.de>
	<20060730211454.ccf803f3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7PVp-0005q0-La
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:36:17 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7PVp-00021x-Jj
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:36:18 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: message from Andrew Morton on Sunday July 30
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

On Sunday July 30, akpm@osdl.org wrote:
> On Mon, 31 Jul 2006 10:42:34 +1000
> NeilBrown <neilb@suse.de> wrote:
> 
> > +static int
> > +svc_pool_map_init_percpu(struct svc_pool_map *m)
> > +{
> > +	unsigned int maxpools = num_possible_cpus();
> > +	unsigned int pidx = 0;
> > +	unsigned int cpu;
> > +	int err;
> > +
> > +	err = svc_pool_map_alloc_arrays(m, maxpools);
> > +	if (err)
> > +		return err;
> > +
> > +	for_each_online_cpu(cpu) {
> > +		BUG_ON(pidx > maxpools);
> > +		m->to_pool[cpu] = pidx;
> > +		m->pool_to[pidx] = cpu;
> > +		pidx++;
> > +	}
> 
> That isn't right - it assumes that cpu_possible_map is not sparse.  If it
> is sparse, we allocate undersized pools and then overindex them.

I don't think so.

At this point we are largely counting the number of online cpus
(in pidx (pool index) - this is returned). The two-way mapping
to_pool and pool_to provides a mapping between the possible-sparse cpu
list and a dense list of pool indexes.

If further cpus come on line they will be automatically included in
pool-0. (as to_pool[n] will still be zero).

Does that make it at all clearer?

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

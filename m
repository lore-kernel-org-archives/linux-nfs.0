From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 010 of 11] knfsd: make rpc threads pools numa aware
Date: Sun, 30 Jul 2006 21:14:54 -0700
Message-ID: <20060730211454.ccf803f3.akpm@osdl.org>
References: <20060731103458.29040.patches@notabene>
	<1060731004234.29291@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7PBA-00043F-WF
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:14:57 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1G7PBA-0003mV-78
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:14:57 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060731004234.29291@suse.de>
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

On Mon, 31 Jul 2006 10:42:34 +1000
NeilBrown <neilb@suse.de> wrote:

> +static int
> +svc_pool_map_init_percpu(struct svc_pool_map *m)
> +{
> +	unsigned int maxpools = num_possible_cpus();
> +	unsigned int pidx = 0;
> +	unsigned int cpu;
> +	int err;
> +
> +	err = svc_pool_map_alloc_arrays(m, maxpools);
> +	if (err)
> +		return err;
> +
> +	for_each_online_cpu(cpu) {
> +		BUG_ON(pidx > maxpools);
> +		m->to_pool[cpu] = pidx;
> +		m->pool_to[pidx] = cpu;
> +		pidx++;
> +	}

That isn't right - it assumes that cpu_possible_map is not sparse.  If it
is sparse, we allocate undersized pools and then overindex them.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Christoph Hellwig <hch@infradead.org>
Subject: Re: patch 38/38: SERVER: giant patch importing NFSv4 server functionality
Date: Wed, 14 Aug 2002 13:43:47 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020814134347.B14609@infradead.org>
References: <Pine.SOL.4.44.0208131912340.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from phoenix.infradead.org ([195.224.96.167])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17exVA-0003nT-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 05:43:53 -0700
To: "Kendrick M. Smith" <kmsmith@umich.edu>
In-Reply-To: <Pine.SOL.4.44.0208131912340.25942-100000@rastan.gpcc.itd.umich.edu>; from kmsmith@umich.edu on Tue, Aug 13, 2002 at 07:12:53PM -0400
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tue, Aug 13, 2002 at 07:12:53PM -0400, Kendrick M. Smith wrote:
> --- old/fs/nfsd/nfssvc.c	Fri Aug  9 11:16:02 2002
> +++ new/fs/nfsd/nfssvc.c	Thu Aug  8 09:53:23 2002
> @@ -77,6 +77,18 @@ nfsd_svc(unsigned short port, int nrserv
>  	int	none_left;
>  	struct list_head *victim;
> 
> +#ifdef CONFIG_NFSD_V4
> +	printk(KERN_INFO "Starting experimental NFSv4 server.\n");
> +	printk(KERN_INFO "Note 1: The NFSv4 pseudo filesystem is not yet implemented!\n");
> +	printk(KERN_INFO "   The first export in your /etc/exports has been arbitrarily\n");
> +	printk(KERN_INFO "   selected as the root of the pseudofs.  In order to see this\n");
> +	printk(KERN_INFO "   export, you will have to mount '/' instead of the export pathname.\n");
> +	printk(KERN_INFO "   Exports other than this one will not be available.\n");
> +	printk(KERN_INFO "Note 2: Most of the NFSv4 state model is not yet implemented;\n");
> +	printk(KERN_INFO "   this server patch should still provide basic functionality.\n");
> +	printk(KERN_INFO "   However, byte-range file locking is not available.\n");
> +#endif

This belongs into a readme, not into kernel messages..



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

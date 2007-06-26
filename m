From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 007 of 8] knfsd: nfsd4: vary maximum delegation
 limit based on RAM size
Date: Mon, 25 Jun 2007 20:52:44 -0700
Message-ID: <20070625205244.bbf0976a.akpm@linux-foundation.org>
References: <20070621142604.727.patches@notabene> <1070621043112.1144@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I327U-0006sS-SU
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 20:53:36 -0700
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I327Y-0003tO-5g
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 20:53:40 -0700
In-Reply-To: <1070621043112.1144@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 21 Jun 2007 14:31:12 +1000 NeilBrown <neilb@suse.de> wrote:

> 
> From: "J. Bruce Fields" <bfields@fieldses.org>
> 
> 
> Our original NFSv4 delegation policy was to give out a read delegation
> on any open when it was possible to.
> 
> Since the lifetime of a delegation isn't limited to that of an open, a
> client may quite reasonably hang on to a delegation as long as it has
> the inode cached.  This becomes an obvious problem the first time a
> client's inode cache approaches the size of the server's total memory.
> 
> Our first quick solution was to add a hard-coded limit.  This patch
> makes a mild incremental improvement by varying that limit according to
> the server's total memory size, allowing at most 4 delegations per
> megabyte of RAM.
> 
> My quick back-of-the-envelope calculation finds that in the worst case
> (where every delegation is for a different inode), a delegation could
> take about 1.5K, which would make the worst case usage about 6% of
> memory.  The new limit works out to be about the same as the old on a
> 1-gig server.
> 
> ...
>  
> +static void
> +set_max_delegations()
> +{
> +	struct sysinfo sys;
> +
> +	si_meminfo(&sys);
> +	sys.totalram *= sys.mem_unit;
> +	sys.totalram >>= (18 - PAGE_SHIFT);
> +	max_delegations = (unsigned int) sys.totalram;
> +}

Please put yourself in the position of the reader who happens across this
code and wonders why it is that way.

They could of course go hunt it out of the git repo but I do think it's
quite a bit more reader-friendly to explain the thinking in code comments.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

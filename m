From: Dave Kleikamp <shaggy@austin.ibm.com>
Subject: Re: [PATCH 3/4] fs: Removing useless casts
Date: Mon, 24 Jul 2006 09:48:51 -0500
Message-ID: <1153752531.10822.8.camel@kleikamp.austin.ibm.com>
References: <20060721140637.GC27097@issaris.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: codalist@TELEMANN.coda.cs.cmu.edu, jaharkes@cs.cmu.edu,
	jfs-discussion@lists.sourceforge.net, nathans@sgi.com,
	mikulas@artax.karlin.mff.cuni.cz, neilb@cse.unsw.edu.au,
	xfs-masters@oss.sgi.com, linux-ntfs-dev@lists.sourceforge.net,
	sct@redhat.com, ext2-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, trond.myklebust@fys.uio.no,
	coda@cs.cmu.edu, vandrove@vc.cvut.cz, jffs-dev@axis.com,
	akpm@osdl.org, aia21@cantab.net, xfs@oss.sgi.com,
	adilger@clusterfs.com, linware@sh.cvut.cz, nfs@lists.sourceforge.net
Return-path: <ext2-devel-bounces@lists.sourceforge.net>
To: takis@issaris.org
In-Reply-To: <20060721140637.GC27097@issaris.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ext2-devel>,
	<mailto:ext2-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ext2-devel>
List-Post: <mailto:ext2-devel@lists.sourceforge.net>
List-Help: <mailto:ext2-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ext2-devel>,
	<mailto:ext2-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ext2-devel-bounces@lists.sourceforge.net
Errors-To: ext2-devel-bounces@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

On Fri, 2006-07-21 at 16:06 +0200, takis@issaris.org wrote:
> From: Panagiotis Issaris <takis@issaris.org>
> 
> * Removing useless casts
> * Removing useless wrapper
> * Conversion from kmalloc+memset to kzalloc
> 
> Signed-off-by: Panagiotis Issaris <takis@issaris.org> 

Acked-by: Dave Kleikamp <shaggy@austin.ibm.com>

The jfs bit is okay.

Shaggy
-- 
David Kleikamp
IBM Linux Technology Center


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV

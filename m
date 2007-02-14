From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] knfsd: Stop NFSD writes from being broken into
 lots of little writes to filesystem.
Date: Wed, 14 Feb 2007 13:44:08 -0800
Message-ID: <20070214134408.431cddcc.akpm@linux-foundation.org>
References: <20070213170049.3488.patches@notabene> <1070213060131.3560@suse.de>
	<45D15687.5080505@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org,
	"Vladimir V \".\" Saveliev" <vs@namesys.com>,
	Norman Weathers <norman.r.weathers@conocophillips.com>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HHRvD-00061A-4R
	for nfs@lists.sourceforge.net; Wed, 14 Feb 2007 13:44:15 -0800
Received: from smtp.osdl.org ([65.172.181.24])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HHRvD-0005qY-Jn
	for nfs@lists.sourceforge.net; Wed, 14 Feb 2007 13:44:16 -0800
In-Reply-To: <45D15687.5080505@yahoo.com.au>
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

On Tue, 13 Feb 2007 17:11:19 +1100
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> NeilBrown wrote:
> > Another nfsd patch for 2.6.21...
> > 
> > ### Comments for Changeset
> > 
> > When NFSD receives a write request, the data is typically in a number
> > of 1448 byte segments and writev is used to collect them together.
> > 
> > Unfortunately, generic_file_buffered_write passes these to the filesystem
> > one at a time, so an e.g. 32K over-write becomes a series of partial-page
> > writes to each page, causing the filesystem to have to pre-read those
> > pages - wasted effort.
> > 
> > generic_file_buffered_write handles one segment of the vector at a
> > time as it has to pre-fault in each segment to avoid deadlocks.  When
> > writing from kernel-space (and nfsd does) this is not an issue, so
> > generic_file_buffered_write does not need to break and iovec from nfsd
> > into little pieces.
> > 
> > This patch avoids the splitting when  get_fs is KERNEL_DS as it is
> > from NFSd.
> > 
> > This issue was introduced by commit 6527c2bdf1f833cc18e8f42bd97973d583e4aa83
> > 
> > Cc: Nick Piggin <nickpiggin@yahoo.com.au>
> 
> FWIW, you can put Acked-by: me there if you'd like.
> 

It's yet another patch we need to revert if/when we get the write()-deadlock
stuff sorted out.  So please add negative-this to that patch series.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

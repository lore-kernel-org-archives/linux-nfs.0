From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] knfsd: Stop NFSD writes from being broken into
 lots of little writes to filesystem.
Date: Tue, 13 Feb 2007 17:11:19 +1100
Message-ID: <45D15687.5080505@yahoo.com.au>
References: <20070213170049.3488.patches@notabene> <1070213060131.3560@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	"Vladimir V \".\" Saveliev" <vs@namesys.com>,
	Norman Weathers <norman.r.weathers@conocophillips.com>
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGqtD-0000ut-LO
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 22:11:43 -0800
Received: from smtp103.mail.mud.yahoo.com ([209.191.85.213])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HGqtE-0004Hz-Rn
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 22:11:45 -0800
In-Reply-To: <1070213060131.3560@suse.de>
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

NeilBrown wrote:
> Another nfsd patch for 2.6.21...
> 
> ### Comments for Changeset
> 
> When NFSD receives a write request, the data is typically in a number
> of 1448 byte segments and writev is used to collect them together.
> 
> Unfortunately, generic_file_buffered_write passes these to the filesystem
> one at a time, so an e.g. 32K over-write becomes a series of partial-page
> writes to each page, causing the filesystem to have to pre-read those
> pages - wasted effort.
> 
> generic_file_buffered_write handles one segment of the vector at a
> time as it has to pre-fault in each segment to avoid deadlocks.  When
> writing from kernel-space (and nfsd does) this is not an issue, so
> generic_file_buffered_write does not need to break and iovec from nfsd
> into little pieces.
> 
> This patch avoids the splitting when  get_fs is KERNEL_DS as it is
> from NFSd.
> 
> This issue was introduced by commit 6527c2bdf1f833cc18e8f42bd97973d583e4aa83
> 
> Cc: Nick Piggin <nickpiggin@yahoo.com.au>

FWIW, you can put Acked-by: me there if you'd like.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

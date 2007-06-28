From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 007 of 8] knfsd: nfsd4: vary maximum delegation
	limit based on RAM size
Date: Wed, 27 Jun 2007 22:57:39 -0400
Message-ID: <20070628025739.GD20605@fieldses.org>
References: <20070621142604.727.patches@notabene> <1070621043112.1144@suse.de>
	<20070625205244.bbf0976a.akpm@linux-foundation.org>
	<20070628021551.GB20605@fieldses.org>
	<20070627193613.746dfbf3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3kCT-0003zD-J1
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 19:57:41 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3kCV-0008L0-Qs
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 19:57:45 -0700
In-Reply-To: <20070627193613.746dfbf3.akpm@linux-foundation.org>
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

On Wed, Jun 27, 2007 at 07:36:13PM -0700, Andrew Morton wrote:
> How's this?

Makes sense to me, thanks.  I guess fs/nsfd/nfssvc:nfsd_create_serv()
should be similarly modified?  It calculates the size of per-nfsd-thread
buffers used to hold requests, which will eventually be allocated with
an alloc_page(GFP_KERNEL), and it bases the calculation on the same
.totalram field from struct sysinfo.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

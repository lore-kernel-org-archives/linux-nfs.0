From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 007 of 8] knfsd: nfsd4: vary maximum delegation
 limit based on RAM size
Date: Wed, 27 Jun 2007 20:10:35 -0700
Message-ID: <20070627201035.dbbb84e7.akpm@linux-foundation.org>
References: <20070621142604.727.patches@notabene> <1070621043112.1144@suse.de>
	<20070625205244.bbf0976a.akpm@linux-foundation.org>
	<20070628021551.GB20605@fieldses.org>
	<20070627193613.746dfbf3.akpm@linux-foundation.org>
	<20070628025739.GD20605@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3kPF-0005KA-5G
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:10:53 -0700
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3kPH-0003py-DE
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:10:56 -0700
In-Reply-To: <20070628025739.GD20605@fieldses.org>
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

On Wed, 27 Jun 2007 22:57:39 -0400 "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jun 27, 2007 at 07:36:13PM -0700, Andrew Morton wrote:
> > How's this?
> 
> Makes sense to me, thanks.  I guess fs/nsfd/nfssvc:nfsd_create_serv()
> should be similarly modified?  It calculates the size of per-nfsd-thread
> buffers used to hold requests, which will eventually be allocated with
> an alloc_page(GFP_KERNEL), and it bases the calculation on the same
> .totalram field from struct sysinfo.

Yup, it'd be better to use nr_free_buffer_pages() there too.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

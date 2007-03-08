From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 16:27:27 -0500
Message-ID: <20070308212727.GA22713@fieldses.org>
References: <20070307194418.97fee0ec.simon.peter@gmx.de>
	<17903.19755.146916.321440@notabene.brown>
	<20070308051401.GC15814@fieldses.org>
	<200703081443.18604.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	nfs@lists.sourceforge.net, Christoph Hellwig <hch@infradead.org>,
	Simon Peter <simon.peter@gmx.de>
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPQ8R-0006m0-Mt
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 13:26:53 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HPQ8S-0002LL-J5
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 13:26:53 -0800
In-Reply-To: <200703081443.18604.olaf.kirch@oracle.com>
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

On Thu, Mar 08, 2007 at 02:43:16PM +0100, Olaf Kirch wrote:
> Now think about handling a system with several thousand exported
> file systems on the server side - if you need to look at each file system
> before nfsd is ready to service requests, we're talking of a considerable
> delay in boot time. In the worst case we're talking about several thousand
> *disks* that need to be spun up, and fuses going pop-pop-pop.
>
> Short summary - if you want to scale beyond small work group servers,
> you need something that scales well. Demand loading the exports
> table does.

There's some confusion here--the reason that this was happening was that
we're mapping filehandles to exports by stat()ing the root of every
exported filesystem.  That may be an obstacle to handling large numbers
of exports, but it's not really related to the demand-loading question.

So why does demand-loading scale better?  Is the worry just the kernel
memory required to store the export table for thousands of mostly
inactive exports?

So you need the mountpoints for the exported filesystem, the export
options, and the name of the client(s).  If that adds up to a few K,
thousands would add up to a few Megs.

Are there other problems?  (E.g. does the VFS handle thousands of mounts
well?)

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

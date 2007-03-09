From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Delays on "first" access to a NFS mount
Date: Fri, 9 Mar 2007 16:02:40 +0100
Message-ID: <200703091602.42090.olaf.kirch@oracle.com>
References: <20070307194418.97fee0ec.simon.peter@gmx.de>
	<200703081443.18604.olaf.kirch@oracle.com>
	<20070308212727.GA22713@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Simon Peter <simon.peter@gmx.de>,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	Christoph Hellwig <hch@infradead.org>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPge1-0002dr-8n
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 07:04:33 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HPge2-0002tB-3l
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 07:04:35 -0800
In-Reply-To: <20070308212727.GA22713@fieldses.org>
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

On Thursday 08 March 2007 22:27, J. Bruce Fields wrote:
> There's some confusion here--the reason that this was happening was that
> we're mapping filehandles to exports by stat()ing the root of every
> exported filesystem.  That may be an obstacle to handling large numbers
> of exports, but it's not really related to the demand-loading question.

Sorry if I was expressing myself poorly. What I was driving at was that
it makes sense to not mount all file systems prior to starting the
NFS server.

> So why does demand-loading scale better?  Is the worry just the kernel
> memory required to store the export table for thousands of mostly
> inactive exports?

It means you can start serving files without having to wait for all 
file systems to be mounted (and having their journals replayed,
etc). All you need is a way for mountd to figure out whether a file system
is there already (so we can push the rootfh into the kernel) or whether it's
not (so nfsd can return EJUKEBOX or defer the request)

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

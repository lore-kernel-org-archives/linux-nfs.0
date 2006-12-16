From: Olaf Kirch <okir@suse.de>
Subject: Re: kernel+userspace based nfsd running in parallel on linux?
Date: Sat, 16 Dec 2006 22:55:44 +0100
Message-ID: <20061216215544.GA5968@suse.de>
References: <1499049521@web.de> <200612161717.31090.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: devzero@web.de, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GvhVX-0002OH-V0
	for nfs@lists.sourceforge.net; Sat, 16 Dec 2006 13:55:52 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GvhVY-0000Vx-7L
	for nfs@lists.sourceforge.net; Sat, 16 Dec 2006 13:55:53 -0800
To: Bernd Schubert <bernd-schubert@gmx.de>
In-Reply-To: <200612161717.31090.bernd-schubert@gmx.de>
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

On Sat, Dec 16, 2006 at 05:17:30PM +0100, Bernd Schubert wrote:
> Hmm, I thing this is presently not possible. I might be wrong, but I think 
> neither knfsd nor any userspace nfs daemon presently supports binding to 
> selected interfaces. Thinks they alsways bind to all interfaces.
> We doing it by using different ports for the daemons, knfsd is running as 
> usual on 2049 and unfsd (unfs3) is running on another port.  One also needs 
> to tell one of the daemon not to register to the portmapper, unfs3 also 
> supports that.

The big problem will be mountd. There's only one portmapper, and you
can register only one mountd - and the file handles given out by unfs
mountd don't work with the kernel nfsd and vice versa.

Oh, and what about locking? :)

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

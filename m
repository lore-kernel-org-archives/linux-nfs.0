From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 23:36:23 -0500
Message-ID: <20070308043623.GA15814@fieldses.org>
References: <20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
	<EXNANE01MWuLn5U9T3T00000074@exnane01.hq.netapp.com>
	<20070307211729.GO26553@fieldses.org>
	<EXNANE0169aZbLAX3cf00000075@exnane01.hq.netapp.com>
	<20070307215406.GR26553@fieldses.org>
	<17903.16030.26119.464793@notabene.brown>
	<20070307232414.GZ26553@fieldses.org>
	<17903.20457.448449.509272@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Simon Peter <simon.peter@gmx.de>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPAM0-0007xr-Dv
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 20:35:48 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPAM2-0007X1-As
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 20:35:50 -0800
In-Reply-To: <17903.20457.448449.509272@notabene.brown>
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

On Thu, Mar 08, 2007 at 10:51:04AM +1100, Neil Brown wrote:
> Well, if you export a different root filesystem to each diskless
> client, or if you export /home to some places and /backup to others,
> then you already have the potential for a different pseudo filesystem
> for each client.  My little hacky shell script above essentially
> merges them all which might be OK, or might not.

I think we want a single export tree, parts of which clients may or may
not have permission to see, rather than try to support per-client
namespaces.  If nothing else, secinfo becomes a bit weird otherwise (do
you tell the client that it can use auth_unix security for this
filesystem, if actually using auth_unix might result in the client
seeing a *different* filesystem?).

> I was just looking at the RFC again and saw this in section 7.3:
> 
>    Based on the construction of the server's name space, it is possible
>    that multiple pseudo filesystems may exist.  For example,
> 
>    /a         pseudo filesystem
>    /a/b       real filesystem
>    /a/b/c     pseudo filesystem
>    /a/b/c/d   real filesystem
> 
>    Each of the pseudo filesystems are considered separate entities and
>    therefore will have a unique fsid.

Hah.

> That adds a whole new dimension of complexity..... do we really want
> to go there?

We certainly aren't required to support every weird configuration that
the RFC allows.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

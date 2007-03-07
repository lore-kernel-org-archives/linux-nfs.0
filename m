From: Simon Peter <simon.peter@gmx.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 00:19:48 +0100
Message-ID: <20070308001948.7496c629.simon.peter@gmx.de>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<20070307202949.GH26553@fieldses.org>
	<20070307224624.d711f47f.simon.peter@gmx.de>
	<20070307220541.GS26553@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP5QT-0002ky-SE
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:20:07 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HP5QU-0006MC-Bd
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:20:08 -0800
In-Reply-To: <20070307220541.GS26553@fieldses.org>
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

> > Not all of my exported directories are mountpoints of the underlying
> > VFS of the server.
> I'd be curious why.  There's some hard-to-solve security problems
> there--people can guess filehandles of unexported files and access
> them directly without lookups.  So some day I'd love to actually
> forbid (or at least strongly discourage) what you're doing....  But
> clearly we'd first need to understand why people do that and make
> sure there are adequate alternatives.

Well, I've actually done it for security (not knowing what you just
said about it). There are some directories on those disks that I don't
want people to poke around in, so I don't export the whole filesystem
of a disk. For some other directories, I have different access
constraints.

For example, there's one subdirectory that I export to two subnets and
one that is only exported to one of them. I do that because I have an
"access granting" security philosophy: At first, any access is denied
and then I grant access only to those people who can make use of their
granted resources. Since one of those directories is only useful to
the users of that one subnet, I only export it for that one.

> > Some are, though.
> Are the spinning-up delays happening only on those drives that have
> exported directories that aren't mountpoints?

I just notice that I was wrong. No exports are on mountpoints. I'm
sorry.

> > Are you sure these are invalidated automatically, especially through
> > nfs-utils? If the kernel cache never expires, it should consequently
> > never ask for it, so nfs-utils would not be involved. Am I missing
> > something?
> There's also a mechanism by which nfs-utils can ask for the whole
> cache to be flushed immediately on its own.  So re-running exportfs
> to change the exports, for example, should result in the cache being
> flushed.  I haven't checked whether that's done in all the places it
> should be, but it probably is.

Okay. So if we really only need major, minor and inode information,
like Neil said, then that would work. Because otherwise the data on
disk could change without the kernel noticing.

Simon

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

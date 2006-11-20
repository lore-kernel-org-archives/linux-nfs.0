From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: nhfsstone license
Date: Mon, 20 Nov 2006 23:26:58 +0100
Message-ID: <20061120222658.GA12819@uio.no>
References: <20061120215305.GA11924@uio.no>
	<20061120222034.GD12285@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, 398058@bugs.debian.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmHce-0004Wr-RA
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 14:28:16 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GmHce-0005tw-Rw
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 14:28:18 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20061120222034.GD12285@fieldses.org>
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

On Mon, Nov 20, 2006 at 05:20:34PM -0500, J. Bruce Fields wrote:
>> If we cannot get this resolved, we'd have to remove nhfsstone from
>> Debian main, which would be rather painful (if nothing else because
>> we'd have to modify the upstream tarball)
> No modification required if we remove it from upstream too.  Do people
> use it?

I've never used it, at least. :-) Debian's "popularity contest"
(popcon.debian.org; it's skewed, but it's still better than nothing) claims
nhfsstone has 74 installations compared to nfs-common's 13910 or
nfs-kernel-server's 4761, so I think it's safe to say it's significantly less
popular than any of the other parts of the package.

Is nhfsstone even reasonably up-to-date with regard to current NFS versions?

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

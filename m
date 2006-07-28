From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] knfsd: Fix stale file handle problem with
	subtree_checking.
Date: Fri, 28 Jul 2006 16:51:56 -0400
Message-ID: <20060728205156.GB12183@fieldses.org>
References: <20060728194103.7245.patches@notabene> <1060728094255.7278@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6ZJX-0006hK-1N
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 13:52:07 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6ZJR-0006rb-Ri
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 13:52:04 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060728094255.7278@suse.de>
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

On Fri, Jul 28, 2006 at 07:42:55PM +1000, NeilBrown wrote:
> The following patch fixes a bug that was introduced since 2.6.17,
> and should go in 2.6.18.
> 
> ### Comments for Changeset
> 
> A recent patch:
> 
>   h=7fc90ec93a5eb71f4b08403baf5ba7176b3ec6b1
> 
> moved the call to nfsd_setuser out of the 'find a dentry for a
> filehandle' branch of fh_verify so that it would always be called.
> 
> This had the unfortunately side-effect of moving *after* the call
> to decode_fh, so the prober fsuid was not set when nfsd_acceptable
> was called, the 'permission' check did the wrong thing.

Argh, sorry, thanks for the fix.

It'd be great if we could deprecate subtree checking some day in the
distant future....

Would it be feasible to add filesystem support for some sort of
subvolume-like thing that acted like a mountpoint (in the sense that it
restricted hardlinks and renames) but that didn't require setting aside
a separate partition?  I imagine that'd probably do what most people
exporting subtrees want without forcing us to do dubious tricks with
filehandles.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

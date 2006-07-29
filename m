From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] knfsd: Fix stale file handle problem with
	subtree_checking.
Date: Sat, 29 Jul 2006 15:29:33 +1000
Message-ID: <17610.62013.790217.817455@cse.unsw.edu.au>
References: <20060728194103.7245.patches@notabene> <1060728094255.7278@suse.de>
	<20060728205156.GB12183@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6hPL-0000Kb-GN
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 22:30:39 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6hPK-0003cc-Eb
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 22:30:40 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Friday July 28
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

On Friday July 28, bfields@fieldses.org wrote:
> 
> It'd be great if we could deprecate subtree checking some day in the
> distant future....

The first step would be to stop it from being the default (as Trond
has suggested a number of times :-)

How about this.
 I release a 1.0.10 shortly which addresses some 'portlist' related
 breakage and prints a nasty warning if you have neither subtree_check
 or no_subtree_check, but still defaults to subtree_check.

 Then the next release will be 1.1.0 which prints the same warning,
 but defaults the other way - and probably removed the warning if you
 include neither sync not async.

That should at least get subtree_check to be used less.

> 
> Would it be feasible to add filesystem support for some sort of
> subvolume-like thing that acted like a mountpoint (in the sense that it
> restricted hardlinks and renames) but that didn't require setting aside
> a separate partition?  I imagine that'd probably do what most people
> exporting subtrees want without forcing us to do dubious tricks with
> filehandles.

I think it is a great idea for a 'filesystem' to support multiple
independent file-trees within the one storage set, which is roughly
what you are saying I think (though probably not quite).

However I suspect that most people don't actually want subtrees.  They
just get it as the default.  It isn't something that I would have
implemented if I hadn't inherited the requirement, and no other OS
that I know of provides that particular semantic.

Maybe we should make it non-default, and then in one year, subtly
break it (maybe reintroduce this bug) and see if anyone notices :-) 
(No, that's unethical, I wouldn't do that - really ....)

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

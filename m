From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] Allow default options in /etc/exports
Date: Mon, 5 Feb 2007 11:35:23 +1100
Message-ID: <17862.31691.37417.435244@notabene.brown>
References: <20061226225848.GA18366@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDrpt-0002kx-Lk
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 16:35:58 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDrpv-0004v6-Ah
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 16:35:59 -0800
In-Reply-To: message from Steinar H. Gunderson on Tuesday December 26
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

On Tuesday December 26, sesse@debian.org wrote:
> [Cc-on-reply, please]

Always.... doesn't everybody?

> 
> Merry Christmas, to those of you who celebrate that. :-) I found some time to
> write a patch for a two-year-old feature request which was slowly getting
> more and more annoying; hope it can go into upstream, even though it won't
> reach our upcoming Debian release.

Yes, I like it.  I've applied it.

I would like to have system-wide defaults too (as you mention).  Any
suggestions on syntax?  Having

-sync,no_root_squash,no_subtree_check

would be syntactically consistent (which is good) but is kind-a ugly.

Thanks,

NeilBrown


> 
> Patch: Allow default options in /etc/exports
> 
>   Implement default options in /etc/exports, to fix a long-standing wishlist
>   bug in Debian. (The user claims the syntax matches that of OpenBSD.) This
>   makes it possible to write "/srv/www -sync,no_subtree_check host1 host2 host3"
>   instead of having to write (sync,no_subtree_check) over and over and over
>   again, driving the administrator slowly mad. Such option lines can be
>   placed anywhere on the line, and affects anything after them (I do not
>   know if OpenBSD allows this). The patch is slightly convoluted in order to
>   avoid triggering spurious warnings; for instance, we want
>   "/srv/www -sync host1" to trigger a warning, but not "/srv/www
>   -sync,no_subtree_check host1" or "/srv/www -sync host1(no_subtree_check)".
> 
>   There was also a suggestion for a truly global (ie. per-file) option list,
>   but this seemed like the safest bet, given that it matches that of other
>   implementations.
> 
>   Also, the man page is updated with information on the new possibilities,
>   and an example.
> 
>   Signed-off-by: Steinar H. Gunderson <sesse@debian.org>

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Neil Brown <neilb@suse.de>
Subject: Re: /etc/exports continue line
Date: Fri, 13 Apr 2007 07:38:56 +1000
Message-ID: <17950.42736.114011.686026@notabene.brown>
References: <461EA1CC.2050102@cogweb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: David Liontooth <liontooth@cogweb.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc70i-0001lP-5Y
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 14:39:20 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hc70j-0005Lq-CF
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 14:39:22 -0700
In-Reply-To: message from David Liontooth on Thursday April 12
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

On Thursday April 12, liontooth@cogweb.net wrote:
> 
> I've been using \ to continue a line in /etc/exports, and ran into an
> odd problem -- if you accidentally hit the TAB key after the continue
> line and save, the entry becomes invalid. Since the TAB key is
> invisible, it can be difficult to figure out what's going on.
> 
> I reported it as Debian bug 418491 to nfs-kernel-server, and the
> maintainer responded by saying \ isn't a valid continue character.
> Comments? I routinely do this sort of thing:
> 
> /spare \
>         165.97.21.130(rw,no_root_squash,no_subtree_check,async) \
>         165.97.21.132(rw,no_subtree_check,async) \
>         165.97.21.133(rw,no_subtree_check,async) \
>         165.97.21.134(rw,no_subtree_check,async) \
>         165.97.21.135(rw,no_root_squash,no_subtree_check,async) \
>         165.97.21.136(rw,no_subtree_check,async) \
>         165.97.85.112(rw,no_subtree_check,async) \
>         165.97.85.117(rw,no_subtree_check,async)
> 
> A lot easier to maintain that a single line. Is there an alternative way
> to continue the line?

Use and editor that highlights spaces at the end of the line???

But yes, I hate '\' line continuation too, for exactly that reason.
The only alternative for /etc/exports is something like:

/spare   165.97.21.130(rw,no_root_squash,no_subtree_check,async)
/spare   165.97.21.132(rw,no_subtree_check,async)
/spare   165.97.21.133(rw,no_subtree_check,async) 
/spare   165.97.21.134(rw,no_subtree_check,async) 
/spare   165.97.21.135(rw,no_root_squash,no_subtree_check,async) 
/spare   165.97.21.136(rw,no_subtree_check,async) 
/spare   165.97.85.112(rw,no_subtree_check,async)
/spare   165.97.85.117(rw,no_subtree_check,async)

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

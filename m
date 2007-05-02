From: Ian Kent <raven@themaw.net>
Subject: Re: /etc/exports continue line
Date: Wed, 02 May 2007 10:38:58 +0800
Message-ID: <1178073538.3393.3.camel@raven.themaw.net>
References: <461EA1CC.2050102@cogweb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: David Liontooth <liontooth@cogweb.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hj4ll-0004TO-HS
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 19:40:41 -0700
Received: from out1.smtp.messagingengine.com ([66.111.4.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hj4lm-0005t8-Tq
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 19:40:44 -0700
In-Reply-To: <461EA1CC.2050102@cogweb.net>
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

On Thu, 2007-04-12 at 14:17 -0700, David Liontooth wrote:
> I've been using \ to continue a line in /etc/exports, and ran into an
> odd problem -- if you accidentally hit the TAB key after the continue
> line and save, the entry becomes invalid. Since the TAB key is
> invisible, it can be difficult to figure out what's going on.
> 
> I reported it as Debian bug 418491 to nfs-kernel-server, and the
> maintainer responded by saying \ isn't a valid continue character.

Well, he's right.

As far as I remember the line continuation has always been "\<NL>",
otherwise you get a solitary <NL> which would end the entry.

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
> 
> Cheers,
> Dave
> 
> 
> -------- Original Message --------
> Subject: 	Re: Bug#418491: nfs-kernel-server: Lots of misleading error
> messages if there's a TAB in /etc/exports
> Date: 	Thu, 12 Apr 2007 16:06:27 +0200
> From: 	Steinar H. Gunderson <sgunderson@bigfoot.com>
> To: 	David Liontooth <liontooth@cogweb.net>, 418491-done@bugs.debian.org
> References:
> <20070410023140.32254.14380.reportbug@localhost.localdomain>
> <20070411002242.GD8811@uio.no>
> 
> 
> 
> On Wed, Apr 11, 2007 at 02:22:42AM +0200, Steinar H. Gunderson wrote:
> >> Try this: edit /etc/exports and add a TAB after a \ (continue line). For instance, mine uses
> > \ isn't supported as continue line, TTBOMK.
> 
> Thus, closing this one; forgot to do so last time.
> 
> /* Steinar */


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

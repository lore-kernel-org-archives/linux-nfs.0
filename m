From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] -EXDEV between mounts that are same fs
Date: Sat, 9 Feb 2008 18:14:35 -0500
Message-ID: <20080209231435.GA20501@fieldses.org>
References: <20080209200503.6a11e88b@poseidon.drzeus.cx>
	<20080209191021.GE25533@fieldses.org>
	<20080209213511.59ff4e2c@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:37823 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754169AbYBIXO5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Feb 2008 18:14:57 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JNyuI-0005Da-Kc
	for linux-nfs@vger.kernel.org; Sun, 10 Feb 2008 10:14:50 +1100
In-Reply-To: <20080209213511.59ff4e2c-mgABNEgzgxm+PRNnhPf8W5YgPPQkE1Si@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 09, 2008 at 09:35:11PM +0100, Pierre Ossman wrote:
> On Sat, 9 Feb 2008 14:10:21 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Sat, Feb 09, 2008 at 08:05:03PM +0100, Pierre Ossman wrote:
> > > Hi,
> > > 
> > > I have a somewhat odd use case that I think has some room for
> > > improvement.
> > > 
> > > I have a single fs exported on the server (/export/data). On the
> > > client I have mount /export/data/a and /export/data/b.  Doing a
> > > rename("/export/data/a/foo", "/export/data/b/foo") results in -EXDEV.
> > 
> > I'm afraid the answer is likely "don't do that!"
> > 
> 
> I don't think I find that an acceptable answer. Giving all systems complete access to your entire server side storage isn't really acceptable in many situations.

I'd be curious to know what you're actually trying to accomplish.  If
you're mounting subdirectories of the same server filesystem, then you
need to be aware that, for example, anyone with access to the network
can probably access that whole filesystem by guessing filehandles (which
is very easy).

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


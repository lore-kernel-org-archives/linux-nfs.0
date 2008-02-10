From: Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
Subject: Re: [NFS] -EXDEV between mounts that are same fs
Date: Sun, 10 Feb 2008 13:12:24 +0100
Message-ID: <20080210131224.1d4ae39f@poseidon.drzeus.cx>
References: <20080209200503.6a11e88b@poseidon.drzeus.cx>
	<20080209191021.GE25533@fieldses.org>
	<20080209213511.59ff4e2c@poseidon.drzeus.cx>
	<20080209231435.GA20501@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:40990 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbYBJMM6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Feb 2008 07:12:58 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JOB3E-0007Hr-LF
	for linux-nfs@vger.kernel.org; Sun, 10 Feb 2008 23:12:52 +1100
In-Reply-To: <20080209231435.GA20501@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 9 Feb 2008 18:14:35 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> > 
> > I don't think I find that an acceptable answer. Giving all systems complete access to your entire server side storage isn't really acceptable in many situations.
> 
> I'd be curious to know what you're actually trying to accomplish.  If
> you're mounting subdirectories of the same server filesystem, then you
> need to be aware that, for example, anyone with access to the network
> can probably access that whole filesystem by guessing filehandles (which
> is very easy).
> 

I thought the subtree check prevented that?

The point of the setup is of course to avoid exposing more information than is necessary, while still having the benefit of having a single pool of disk space for all exported resources.

Rgds
-- 
     -- Pierre Ossman

  Linux kernel, MMC maintainer        http://www.kernel.org
  PulseAudio, core developer          http://pulseaudio.org
  rdesktop, core developer          http://www.rdesktop.org

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


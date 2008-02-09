From: Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
Subject: Re: [NFS] -EXDEV between mounts that are same fs
Date: Sat, 9 Feb 2008 21:35:11 +0100
Message-ID: <20080209213511.59ff4e2c@poseidon.drzeus.cx>
References: <20080209200503.6a11e88b@poseidon.drzeus.cx>
	<20080209191021.GE25533@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54968 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754820AbYBIUfh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Feb 2008 15:35:37 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JNwQA-0004nk-Rv
	for linux-nfs@vger.kernel.org; Sun, 10 Feb 2008 07:35:34 +1100
In-Reply-To: <20080209191021.GE25533@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 9 Feb 2008 14:10:21 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Sat, Feb 09, 2008 at 08:05:03PM +0100, Pierre Ossman wrote:
> > Hi,
> > 
> > I have a somewhat odd use case that I think has some room for
> > improvement.
> > 
> > I have a single fs exported on the server (/export/data). On the
> > client I have mount /export/data/a and /export/data/b.  Doing a
> > rename("/export/data/a/foo", "/export/data/b/foo") results in -EXDEV.
> 
> I'm afraid the answer is likely "don't do that!"
> 

I don't think I find that an acceptable answer. Giving all systems complete access to your entire server side storage isn't really acceptable in many situations.

> > 
> > So, would it be possible to actually make the kernel realise that the
> > source and target are in face the same fs on the server (so a NFS
> > rename will succeed)? Or at least make the kernel present different
> > device st_dev for the two trees.
> 
> I believe the same thing happens even with --bind mounts of the same
> local filesystem, and that it's by design.  See this discussion:
> 
> 	http://marc.info/?t=119801816800006&r=1&w=2
> 

They make some sound arguments for it, so I guess the optimisation is out of the question. I also couldn't find anything in POSIX linking rename() and st_dev, so it should be fine from a strict interpretation of the spec. Still, it is a bit unexpected to get -EXDEV when st_dev is the same for both points.

I though the NFS client allocates "fake" st_dev numbers to guarantee the st_dev/st_ino uniqueness, so how come each mount point doesn't get a new one?

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


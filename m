Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:40217 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752398Ab0DLTog (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Apr 2010 15:44:36 -0400
Received: from brown by neil.brown.name with local (Exim 4.71)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1O1PYg-0004MO-9r
	for linux-nfs@vger.kernel.org; Tue, 13 Apr 2010 05:44:34 +1000
Date: Mon, 12 Apr 2010 15:44:00 -0400
To: Bernd Schubert <bernd.schubert@fastmail.fm>
Subject: Re: nfs + Reiser4
Message-ID: <20100412194400.GE22542@fieldses.org>
References: <op.vaq49joctxpshh@localhost.localdomain>
	<201004080044.38451.bernd.schubert@fastmail.fm>
In-Reply-To: <201004080044.38451.bernd.schubert@fastmail.fm>
From: "J. Bruce Fields" <bfields@fieldses.org>
Cc: nfs@lists.sourceforge.net
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Apr 08, 2010 at 12:44:38AM +0200, Bernd Schubert wrote:
> On Tuesday 06 April 2010, gg@catking.net wrote:
> > Hi,
> > 
> > I am having serious headaches using nfs between a reiser4 server and arm
> > client.
> > Both on 2.6.29 vintage kernels.
> > 
> > Files are constantly getting out of sync.
> > 
> > Example :
> > 
> > boot ARM via nfs
> > edit lighttpd.conf on ARM
> > check edit is visible on server. OK
> > 
> > reboot ARM
> > check file : reverted to an earlier state.
> > check server: edited version still showing.
> > 
> > 
> > This is just one example of serious userablity issues. I have also seen a
> > revert 10s later reopening the same file on the ARM.
> > 
> > Is this possibly related to R4 + nfs ?
> 
> Reminds me about an old bug report I wrote and which nobody ever cared about:
> 
> http://article.gmane.org/gmane.linux.nfs/9867/match=

On a possibly-too-quick skim, I think this could be explained by just
stale cache data, possibly the result of poor ext3 time resolution.
(Still a bug of some kind, but not as bizarre as the bug reported here.)

--b.

------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


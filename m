Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:57331 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757360AbZDWNSJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 09:18:09 -0400
Subject: Re: Client NFS pachtes workflow
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Kasparek Tomas <kasparek@fit.vutbr.cz>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20090423123803.GH57877@fit.vutbr.cz>
References: <20090423123803.GH57877@fit.vutbr.cz>
Content-Type: text/plain
Date: Thu, 23 Apr 2009 09:18:05 -0400
Message-Id: <1240492685.8240.55.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2009-04-23 at 14:38 +0200, Kasparek Tomas wrote:
> Hi,
> 
> while searching some more info for my problems with 2.6.27.x & client
> packet flow & lockd, I tried to find the flow of patches for NFS clients.
> For older one, there are dierctories in
> http://www.linux-nfs.org/Linux-2.6.x/ (up to 28-rc9). Does it mean patches
> in 2.7.27 originated in time after 2.6.27 was out and were included in
> 28-rc5 (next dir). Some of the patches seem to correct bugs, do they get
> into 27.x by default or is it necessary to ask somewhere (GregKH)? 

The main method of tracking patches is rather through the git tree. The
patches on client.linux-nfs.org are only being sporadically updated.
However, yes, the patches in the 2.6.27 subdir are meant to be applied
to 2.6.27. Some of the bugfixes will find their way into the -stable
series, but not all (it depends on how serious the bug is, and how
intrusive the fix is).

> I found http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git, but that seems to
> be just tracking branches, is it possible to use that tree to track NFS
> client changes easily? (I'm not git power user so maybe it's just about
> knowing the right command).

You can find the stuff that is considered merge-ready in the linux-next
branch. Just pull it into your main branch.
i.e. something like

	git clone git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git
	git checkout -b testing
	git merge origin/linux-next

Trond


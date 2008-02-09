From: Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
Subject: Re: [NFS] -EXDEV between mounts that are same fs
Date: Sat, 9 Feb 2008 21:57:00 +0100
Message-ID: <20080209215700.021329ec@poseidon.drzeus.cx>
References: <20080209200503.6a11e88b@poseidon.drzeus.cx>
	<20080209191021.GE25533@fieldses.org>
	<20080209213511.59ff4e2c@poseidon.drzeus.cx>
	<1202589611.11035.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:52473 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753857AbYBIU51 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Feb 2008 15:57:27 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JNwlI-0004rW-P6
	for linux-nfs@vger.kernel.org; Sun, 10 Feb 2008 07:57:24 +1100
In-Reply-To: <1202589611.11035.0.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 09 Feb 2008 15:40:11 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> It has the same syntax and properties as a bind mount. If you don't like
> it, then fix the VFS.
> 

So it detects that it is the same server and server side fs and reuses the super block?

> Those semantics are _exactly_ the same as if you were to mount --bind
> the same filesystem to two different mountpoints. This is not an NFS
> bug, but rather a deliberate design within the VFS in order to avoid
> mutex locking deadlocks during rename.

Do you have a reference for that? The previous thread linked in suggested it was a security feature.

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


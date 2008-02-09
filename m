From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] -EXDEV between mounts that are same fs
Date: Sat, 09 Feb 2008 15:03:21 -0500
Message-ID: <1202587401.8305.10.camel@heimdal.trondhjem.org>
References: <20080209200503.6a11e88b@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:47460 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755358AbYBIUEK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Feb 2008 15:04:10 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JNvvj-0004iS-Cj
	for linux-nfs@vger.kernel.org; Sun, 10 Feb 2008 07:04:07 +1100
In-Reply-To: <20080209200503.6a11e88b-mgABNEgzgxm+PRNnhPf8W5YgPPQkE1Si@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sat, 2008-02-09 at 20:05 +0100, Pierre Ossman wrote:
> Hi,
> 
> I have a somewhat odd use case that I think has some room for improvement.
> 
> I have a single fs exported on the server (/export/data). On the client I have mount /export/data/a and /export/data/b. Doing a rename("/export/data/a/foo", "/export/data/b/foo") results in -EXDEV.
> 
> Now this is a bit annoying from a program point of view as it is very difficult to detect this beforehand. Doing a stat() on source and destination indicates that they are the same fs. So it would seem POSIX would guarantee I would not get a -EXDEV in that case. I assume this is simply a local, client-side check that determines that two different mount entries are involved.
> 
> So, would it be possible to actually make the kernel realise that the source and target are in face the same fs on the server (so a NFS rename will succeed)? Or at least make the kernel present different device st_dev for the two trees.
> 
> Rgds

Those semantics are _exactly_ the same as if you were to mount --bind
the same filesystem to two different mountpoints. This is not an NFS
bug, but rather a deliberate design within the VFS in order to avoid
mutex locking deadlocks during rename.

Cheers
  Trond


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


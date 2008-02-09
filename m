From: Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
Subject: [NFS] -EXDEV between mounts that are same fs
Date: Sat, 9 Feb 2008 20:05:03 +0100
Message-ID: <20080209200503.6a11e88b@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36291 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754128AbYBITFd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Feb 2008 14:05:33 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JNv0w-0004Hn-6b
	for linux-nfs@vger.kernel.org; Sun, 10 Feb 2008 06:05:26 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have a somewhat odd use case that I think has some room for improvement.

I have a single fs exported on the server (/export/data). On the client I have mount /export/data/a and /export/data/b. Doing a rename("/export/data/a/foo", "/export/data/b/foo") results in -EXDEV.

Now this is a bit annoying from a program point of view as it is very difficult to detect this beforehand. Doing a stat() on source and destination indicates that they are the same fs. So it would seem POSIX would guarantee I would not get a -EXDEV in that case. I assume this is simply a local, client-side check that determines that two different mount entries are involved.

So, would it be possible to actually make the kernel realise that the source and target are in face the same fs on the server (so a NFS rename will succeed)? Or at least make the kernel present different device st_dev for the two trees.

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


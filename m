From: Iustin Pop <iusty-JC6qDa14zzLYtjvyW6yDsg@public.gmane.org>
Subject: [NFS] Problems with crossmnt since 1.2.1
Date: Sun, 28 Feb 2010 10:58:23 +0100
Message-ID: <20100228095823.GC26178@teal.hq.k1024.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:38266 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031766Ab0B1KvZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Feb 2010 05:51:25 -0500
Received: from brown by neil.brown.name with local (Exim 4.71)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Nlgk7-00013z-8p
	for linux-nfs@vger.kernel.org; Sun, 28 Feb 2010 21:51:23 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Since nfs-utils 1.2.1, there are some problems with crossmnt usage. See
Debian bug http://bugs.debian.org/567546, but in short the problem seems
to be that sub-mounts (/a/b) take the top-level mount (/a) options
instead of their own, due to a bug in how mountd generates the crossmnt
subexports.

I checked that reverting the write_secinfo changes in commit
bc0a6ab03089fc1ea4fea26ed9635c2cc918b01b fix the issue, but that might
only be a side effect, not the actual cause.

A short test:
- have /a and /a/b exported, with different flags (e.g. ro on /a, rw on
  /a/b)
- restart the mountd, clear exports, etc.
- try a mount on the client of /a/b, it gets readonly
- umount & remount, it's now r/w
- however, clearing the kernel export table (exportfs -f), makes the
  next mount again get read-only 

Disabling crossmnt fixes the issue completely, so I would venture to
guess that the subexports creation code has some issue, but I don't know
enough of this to be able to debug it.

thanks,
iustin

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


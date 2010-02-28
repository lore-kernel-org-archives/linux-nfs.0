From: Iustin Pop <iusty-JC6qDa14zzLYtjvyW6yDsg@public.gmane.org>
Subject: Problems with crossmnt since 1.2.1
Date: Sun, 28 Feb 2010 11:06:43 +0100
Message-ID: <20100228100643.GG26178@teal.hq.k1024.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:15280 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031648Ab0B1KGq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Feb 2010 05:06:46 -0500
Received: by fg-out-1718.google.com with SMTP id 16so492676fgg.1
        for <linux-nfs@vger.kernel.org>; Sun, 28 Feb 2010 02:06:45 -0800 (PST)
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

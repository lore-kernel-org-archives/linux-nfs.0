Return-Path: linux-nfs-owner@vger.kernel.org
Received: from trent.utfs.org ([94.185.90.103]:51458 "EHLO trent.utfs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753158Ab3HLI3U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Aug 2013 04:29:20 -0400
Date: Mon, 12 Aug 2013 01:29:15 -0700 (PDT)
From: Christian Kujau <lists@nerdbynature.de>
To: Karl Schmidt <karl@xtronics.com>
cc: jfs-discussion@lists.sourceforge.net, Jonathan McDowell <noodles@earth.li>,
        linux-nfs@vger.kernel.org, 714974@bugs.debian.org,
        Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [Jfs-discussion] NFS 'readdir loop' error on JFS
In-Reply-To: <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org>
Message-ID: <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org>
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk> <520554A5.3060401@xtronics.com> <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org> <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the noise, here's another oddity, same setup (client & server 
running 3.11-rc5):

$ find /mnt/nfs/usr/share/ -name getopt.awk -ls
 25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
 25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
 25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
 25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
 25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
 25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
 25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
 25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
 25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
 25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk

It's the same file, but gets reported 10 times! Hence the error when 
trying to tar(1) the directory:

$ tar -cf - /mnt/nfs/usr/share/awk/ > /dev/null
tar: Removing leading `/' from member names
tar: /mnt/nfs/usr/share/awk/: Cannot savedir: Too many levels of symbolic links
tar: Exiting with failure status due to previous errors

On the server:

$ find /mnt/disk/usr/share/ -name getopt.awk -ls
 25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/disk/usr/share/awk/getopt.awk

So, is "JFS && NFS" really br0ken and nobody noticed?

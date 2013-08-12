Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53000 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755180Ab3HLQ3i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Aug 2013 12:29:38 -0400
Date: Mon, 12 Aug 2013 12:29:24 -0400
To: Christian Kujau <lists@nerdbynature.de>
Cc: Karl Schmidt <karl@xtronics.com>, jfs-discussion@lists.sourceforge.net,
        Jonathan McDowell <noodles@earth.li>, linux-nfs@vger.kernel.org,
        714974@bugs.debian.org, Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [Jfs-discussion] NFS 'readdir loop' error on JFS
Message-ID: <20130812162924.GB2395@fieldses.org>
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk>
 <520554A5.3060401@xtronics.com>
 <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org>
 <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org>
 <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 12, 2013 at 01:29:15AM -0700, Christian Kujau wrote:
> Sorry for the noise, here's another oddity, same setup (client & server 
> running 3.11-rc5):
> 
> $ find /mnt/nfs/usr/share/ -name getopt.awk -ls
>  25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
>  25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
>  25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
>  25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
>  25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
>  25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
>  25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
>  25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
>  25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
>  25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/nfs/usr/share/awk/getopt.awk
> 
> It's the same file, but gets reported 10 times! Hence the error when 
> trying to tar(1) the directory:
> 
> $ tar -cf - /mnt/nfs/usr/share/awk/ > /dev/null
> tar: Removing leading `/' from member names
> tar: /mnt/nfs/usr/share/awk/: Cannot savedir: Too many levels of symbolic links
> tar: Exiting with failure status due to previous errors
> 
> On the server:
> 
> $ find /mnt/disk/usr/share/ -name getopt.awk -ls
>  25072    4 -rw-r--r--   1 root     root         2237 Mar 16 04:46 /mnt/disk/usr/share/awk/getopt.awk
> 
> So, is "JFS && NFS" really br0ken and nobody noticed?

It does sound like a jfs bug, and I don't know if anyone tests nfs
exports of jfs regularly.

It might be interesting to get a network trace (something like tcpdump
-s0 -wtmp.pcap; then "wireshark tmp.pcap" and look at the "cookie"
fields in the readdir calls and replies.  The server shouldn't return
the same one twice on one read through the directory.  And when the
client uses a cookie it should get the next entries, not
already-returned entries.)

You could also just run "strace -egetdents64 -v ls" on the server on
the exported filesystem, in a problem directory, and see if the offsets
are unique.

--b.

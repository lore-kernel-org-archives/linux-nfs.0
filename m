Return-Path: linux-nfs-owner@vger.kernel.org
Received: from trent.utfs.org ([94.185.90.103]:58740 "EHLO trent.utfs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754868Ab3HLUFG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Aug 2013 16:05:06 -0400
Date: Mon, 12 Aug 2013 13:04:56 -0700 (PDT)
From: Christian Kujau <lists@nerdbynature.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: Karl Schmidt <karl@xtronics.com>, Jonathan McDowell <noodles@earth.li>,
        jfs-discussion@lists.sourceforge.net, 714974@bugs.debian.org,
        Ben Hutchings <ben@decadent.org.uk>, linux-nfs@vger.kernel.org,
        dave.kleikamp@oracle.com
Subject: Re: [Jfs-discussion] NFS 'readdir loop' error on JFS
In-Reply-To: <20130812162924.GB2395@fieldses.org>
Message-ID: <alpine.DEB.2.10.1308121257020.7081@trent.utfs.org>
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk> <520554A5.3060401@xtronics.com> <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org> <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org> <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org>
 <20130812162924.GB2395@fieldses.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 12 Aug 2013 at 12:29, J. Bruce Fields wrote:
> It might be interesting to get a network trace (something like tcpdump
> -s0 -wtmp.pcap; then "wireshark tmp.pcap" and look at the "cookie"
> fields in the readdir calls and replies.

I've created #60737[0] to track this issue upstream and attached a pcap to 
the bug, obtained while running "find <dir> -ls" on the client. But I fail 
to look at the right details in tcpdump/wireshare, I don't see any cookie 
information...

> You could also just run "strace -egetdents64 -v ls" on the server on
> the exported filesystem, in a problem directory, and see if the offsets
> are unique.

strace returned nothing for "getdents64", only "getdents". My test 
filesystems are 256 MB in size, maybe this is too small for getdents64 to 
be used? All the calls to "getdents" however return unique offsets, if I 
did this right:

$ strace -egetdents -v ls /mnt/disk_jfs/usr/share/terminfo/q 2>&1 | egrep -o "d_off=[0-9]*" | sort

When running "ls" (even w/o "-l") on the client on that NFS share, this 
"readdir loop" message is printed.

HTH,
Christian.

[0] https://bugzilla.kernel.org/show_bug.cgi?id=60737

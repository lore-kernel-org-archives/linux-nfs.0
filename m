Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:38079 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754438Ab3CZRhv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Mar 2013 13:37:51 -0400
Date: Tue, 26 Mar 2013 17:37:47 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Toralf F??rster <toralf.foerster@gmx.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: kernel 3.8.4 : kernel BUG at fs/locks.c:2093!   part #2
Message-ID: <20130326173747.GV21522@ZenIV.linux.org.uk>
References: <514F31AF.3080709@gmx.de>
 <20130325220143.GD10887@fieldses.org>
 <20130326144640.GB3353@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130326144640.GB3353@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 26, 2013 at 10:46:40AM -0400, J. Bruce Fields wrote:
> > fs/locks.c:2093 says that we did the final fput of a file that still had
> > posix locks held on it.
> > 
> > I can't see how that would happen, but admittedly the nfsd4 code here is
> > much too complicated for its own good.
> > 
> > If it were possible it would be useful to know what lead up to this.  A
> > network trace (tcpdump -s0 -wtmp.pcap, then send me tmp.pcap) would be
> > useful for that, but I fear it's probably too huge by the time you hit
> > the bug.
> > 
> > (The following warning ("rcu_sched self-detected stall") looks like the
> > result of BUGing while holding file_lock_lock.  That BUG should probably
> > be downgraded to a WARN_ON_ONCE.)
> 
> Can you run with test patches?
> 
> This just makes nfsd's fput calls synchronous so that we see in the
> backtrace who called them.
> 
> (But assuming it does turn out to be one of these callers, we may then
> need some more printk's in the nfsd code...).

Might also be a good idea to dump the offending struct file_lock, while
we are at it...

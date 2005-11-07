From: Andre Noll <maan@systemlinux.org>
Subject: Re: [NFS] Re: BUG: soft lockup detected on CPU#0! (linux-2.6.14)
Date: Mon, 7 Nov 2005 17:16:05 +0100
Message-ID: <20051107161605.GH26862@skl-net.de>
References: <20051106193142.GD26862@skl-net.de> <17262.31781.497775.640424@cse.unsw.edu.au> <20051106225138.GF26862@skl-net.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964857AbVKGQQZ@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
In-Reply-To: <20051106225138.GF26862@skl-net.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On 23:51, Andre Noll wrote:
> > The following patch might fix it.  Please let me know the result.
> 
> Patch applied and rebooted. The box currently compiles glibc and
> firefox in parallel. No problems so far.

Just want to confirm that your patch indeed fixed the problem. I
can't reproduce the bug message any more.

Thanks again
Andre
-- 
Jesus not only saves, he also frequently makes backups

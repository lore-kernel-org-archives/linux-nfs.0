From: Duncan <1i5t5.duncan@cox.net>
Subject: Re: btrfs: kernel BUG at mm/page-writeback.c:2286!
Date: Tue, 19 May 2015 13:00:37 +0000 (UTC)
Message-ID: <pan$af9b8$8bb6af9f$b6451669$1f3d25ac@cox.net>
References: <alpine.LNX.2.03.1505191317300.21108@ws.cisco>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Govindarajulu Varadarajan posted on Tue, 19 May 2015 13:25:49 +0530 as
excerpted:

> I am seeing the following crash on my btrfs filesystem with nfs export.
> If I disable the nfs share and reboot, I do not hit the crash. Look like
> the crash happens on btrfs with nfs export.
> 
> Is this a known issue? Has anyone else faced this?

[Just a quick info-relay reply here; I'm not a dev and don't use nfs.  
Hopefully someone with more information will reply given a few more hours 
or a day or two...]

The issue has been reported by several people, now, yes.  There has also 
been kernel dev discussion of a problem with nfs 2.x, with a patch in 
progress (don't know if it's applied yet), but it hasn't been clear, at 
least to me, whether all reports correspond to that or not.

Now that you know that much, if you don't get a better reply in a day or 
two, or while you are waiting, you can check the (btrfs) list archive for 
more information.

-- 
Duncan - List replies preferred.   No HTML msgs.
"Every nonfree program has a lord, a master --
and if you use the program, he is your master."  Richard Stallman

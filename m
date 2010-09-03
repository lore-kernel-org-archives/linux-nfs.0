Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51571 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372Ab0ICTMs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Sep 2010 15:12:48 -0400
From: Maciej Rutecki <maciej.rutecki@gmail.com>
Reply-To: maciej.rutecki@gmail.com
To: tim.gardner@canonical.com
Subject: Re: nfsd deadlock, 2.6.36-rc3
Date: Fri, 3 Sep 2010 21:12:43 +0200
Cc: linux-nfs@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        neilb@suse.de, bfields@fieldses.org, Trond.Myklebust@netapp.com
References: <4C7E73CB.7030603@canonical.com>
In-Reply-To: <4C7E73CB.7030603@canonical.com>
Content-Type: Text/Plain;
  charset="utf-8"
Message-Id: <201009032112.43524.maciej.rutecki@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On środa, 1 września 2010 o 17:39:55 Tim Gardner wrote:
> I've been pursuing a simple reproducer for an NFS lockup that shows up
> under stress. There is a bunch of info (some of it extraneous) in
> http://bugs.launchpad.net/bugs/561210. I can reproduce it by writing
> loop mounted NFS exports:
> 
> /etc/fstab: 127.0.0.1:/srv /mnt/srv nfs rw 0 2
> /etc/exports: /srv 127.0.0.1(rw,insecure,no_subtree_check)
> 
> See the attached scripts test_master.sh and test_client.sh. I simply
> repeat './test_master.sh wait' until nfsd locks up, typically within 1-3
> cycles, e.g.,
> 
> cd /mnt/srv
> while true; do ./test_master.sh wait; done
> 
> Note that this test will run indefinitely if invoked from /srv, e.g.,
> 
> cd /srv
> while true; do ./test_master.sh wait; done
> 
> This issue, or something like it, appears to exist as far back as I've
> tested (Ubuntu Lucid 2.6.32.21). For now I'm assuming that, since the
> symptoms are similar, any lockup bug found in -rc3 is the likely culprit.
> 
> See attached dmesg and config. Debug options of interest that I've
> enabled are CONFIG_DEBUG_SLAB, CONFIG_DEBUG_SLAB_LEAK,
> CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_MUTEXES.
> 
> dmesg.txt contains the initial 'INFO: task nfsd:1263 blocked for more
> than 120 seconds.' complaints as well as information dumped from
> 
> echo d | sudo tee /proc/sysrq-trigger
> echo w | sudo tee /proc/sysrq-trigger
> 
> Anything else I can provide?
> 
> rtg

I created a Bugzilla entry at 
https://bugzilla.kernel.org/show_bug.cgi?id=17762
for your bug report, please add your address to the CC list in there, thanks!

-- 
Maciej Rutecki
http://www.maciek.unixy.pl

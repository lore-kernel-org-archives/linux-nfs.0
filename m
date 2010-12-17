Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:53667 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755287Ab0LQUpj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Dec 2010 15:45:39 -0500
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: persistent, quasi-random -ESTALE at mount time
References: <87mxra6duq.fsf@spindle.srvr.nix>
	<20100922155235.GE15560@fieldses.org>
	<8762xwqijb.fsf@spindle.srvr.nix> <20101001220018.GE1472@fieldses.org>
	<87zkux5ye1.fsf@spindle.srvr.nix>
	<20101001231144.GB12203@fieldses.org>
From: Nix <nix@esperi.org.uk>
Date: Fri, 17 Dec 2010 20:45:34 +0000
In-Reply-To: <20101001231144.GB12203@fieldses.org> (J. Bruce Fields's message of "Fri, 1 Oct 2010 19:11:44 -0400")
Message-ID: <878vzo5dsh.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2 Oct 2010, J. Bruce Fields stated:

> On Fri, Oct 01, 2010 at 11:41:42PM +0100, Nix wrote:
>> I mean, yes, we can work around it by killing rpc.mountd and restarting
>> it as soon as the server has booted, but, well, yuck, no thanks, too
>> much of a kludge. I'll have a concentrated hunt for the bug soon (once I
>> can reproduce it without rebooting the single largest machine I have
>> root on!)
>
> OK, thanks for the persistence, and apologies that I can't think of
> anything off the top of my head (and haven't had the time to try and
> look more closely).  I'll look forward to anything more you can figure
> out....

This is still happening. Just by chance (while checking to see if adding
unique fsids to every line fixed it: no) I spotted something
interesting, which I think points to the cause.

You don't need to repeatedly kill rpc.mountd and restart it at all to
fix things. You just have to run exportfs many times!

Here are dumps of /proc/fs/nfs/exports on boot (after a single exportfs -ra),
then after a subsequent one, then another:

# Version 1.1
# Path Client(Flags) # IPs
/var/state/munin	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=17,uuid=b5cb6e6b:ed9d4345:abd64535:f56e2519)
/usr/share/xplanet	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=9,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/share/httpd/htdocs/munin	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=18,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/share/xemacs	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=8,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/share/texlive	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=7,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/share/nethack	mutilate.wkstn.nix(rw,root_squash,async,wdelay,fsid=10,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/lib/X11/fonts	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=12,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/share/clamav	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=19,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/doc	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=5,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/src	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=16,uuid=333950aa:8e3f440a:bc94d0cc:4adae198)

# Version 1.1
# Path Client(Flags) # IPs
/var/state/munin	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=17,uuid=b5cb6e6b:ed9d4345:abd64535:f56e2519)
/usr/share/xplanet	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=9,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/etc/shai-hulud	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=15,uuid=6c0f7fa7:d6c24054:bff33a87:8460bdc7)
/usr/share/httpd/htdocs/munin	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=18,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/share/xemacs	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=8,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/home/.spindle.srvr.nix/nix/Graphics/Photos	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=3,uuid=78c50891:aaac452b:8b4fa769:9565a21e)
/usr/share/texlive	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=7,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/share/nethack	mutilate.wkstn.nix(rw,root_squash,async,wdelay,fsid=10,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/var/log.real	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=14,uuid=b5cb6e6b:ed9d4345:abd64535:f56e2519)
/usr/lib/X11/fonts	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=12,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/share/clamav	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=19,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/home/.spindle.srvr.nix	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=1,uuid=95bd22c2:253c456f:8e36b6cf:b9ecd4ef)
/usr/doc	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=5,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/src	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=16,uuid=333950aa:8e3f440a:bc94d0cc:4adae198)
/usr/info	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=6,uuid=5cccc224:a92440ee:b4450447:3898c2ec)

# Version 1.1
# Path Client(Flags) # IPs
/var/state/munin	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=17,uuid=b5cb6e6b:ed9d4345:abd64535:f56e2519)
/usr/share/xplanet	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=9,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/etc/shai-hulud	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=15,uuid=6c0f7fa7:d6c24054:bff33a87:8460bdc7)
/usr/share/httpd/htdocs/munin	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=18,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/share/xemacs	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=8,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/home/.spindle.srvr.nix/nix/Graphics/Photos	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=3,uuid=78c50891:aaac452b:8b4fa769:9565a21e)
/usr/share/texlive	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=7,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/share/nethack	mutilate.wkstn.nix(rw,root_squash,async,wdelay,fsid=10,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/var/log.real	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=14,uuid=b5cb6e6b:ed9d4345:abd64535:f56e2519)
/home/.spindle.srvr.nix/nix/Mail/nnmh/spambox-verified	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=2,uuid=52d386c2:b6384034:8bd4e199:5e3237bb)
/usr/lib/X11/fonts	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=12,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/share/clamav	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=19,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/home/.spindle.srvr.nix	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=1,uuid=95bd22c2:253c456f:8e36b6cf:b9ecd4ef)
/pkg/non-free	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=11,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/usr/doc	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=5,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
/home/.spindle.srvr.nix	fold.srvr.nix(rw,root_squash,async,wdelay,no_subtree_check,fsid=1,uuid=95bd22c2:253c456f:8e36b6cf:b9ecd4ef)
/usr/src	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=16,uuid=333950aa:8e3f440a:bc94d0cc:4adae198)
/usr/info	mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=6,uuid=5cccc224:a92440ee:b4450447:3898c2ec)

If exportfs is not correctly exporting everything to the kernel when
run, that would pretty much explain the cause of spontaneous -ESTALEs on
reboot, because rebooting clears the mount table: if a single exportfs
is failing to properly refill it, mountd is going to say -ESTALE about
everything it forgot to put back in.


I'll scatter debugging through exportfs and try to see what it's doing
wrong.

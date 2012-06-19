Return-Path: linux-nfs-owner@vger.kernel.org
Received: from riis.snl.salk.edu ([198.202.70.55]:39920 "EHLO
	riis.snl.salk.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688Ab2FSTvw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jun 2012 15:51:52 -0400
From: Chris Hiestand <chiestand@salk.edu>
Content-Type: text/plain; charset=us-ascii
Subject: NFS: kernel forces trailing slash for export in /proc/self/mounts
Date: Tue, 19 Jun 2012 12:43:59 -0700
Message-Id: <8F8193BD-84C6-4905-8789-DE7EB2579A4E@salk.edu>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        669314@bugs.debian.org
To: viro@zeniv.linux.org.uk
Mime-Version: 1.0 (Apple Message framework v1278)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Alexander Viro et al,

This is an escalation of Debian Bug #669314 http://bugs.debian.org/669314, which I will
re-elaborate in this email for your convenience.

You committed a change to the way the linux kernel reports NFS mounts - now with a
trailing slash for the remote export (among other changes). The change happened here:
> commit c7f404b40a3665d9f4e9a927cc5c1ee0479ed8f9
> Author: Al Viro <viro@zeniv.linux.org.uk>
> Date:   Wed Mar 16 06:59:40 2011 -0400
> 
>     vfs: new superblock methods to override /proc/*/mount{s,info}
>     
>     a) ->show_devname(m, mnt) - what to put into devname columns in mounts,
>     mountinfo and mountstats
>     b) ->show_path(m, mnt) - what to put into relative path column in mountinfo
>     
>     Leaving those NULL gives old behaviour.  NFS switched to using those.
>     
>     Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> 

The "problematic" behavior is that NFS exports now have a trailing slash in
/proc/self/mounts.

This still seems to be the case in newer kernels, for example in Debian's
3.3.2-1~experimental.1.

and HEAD in Linus Torvalds' master branch, presently commit:
02edf6abe01610a5fb379df442de3c837ad99467


I believe it is/was convention to leave a trailing slash off of the nfs export
in /etc/fstab, e.g.:
nfsserver:/srv/ubuntu-32 /mnt/ubuntu-32  nfs ro,nfsvers=3,soft,intr,tcp,nodev,noatime,nosuid,rsize=32768,wsize=32768

and I'd also expect the same in /proc/self/mounts


Expected Result:
I expect /proc/self/mounts to show (notice no trailing slash on the export):
nfsserver:/srv/ubuntu-32 /mnt/ubuntu-32 nfs ro,nosuid,nodev,noatime,vers=3,rsize=32768,wsize=32768,namlen=255,soft,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=198.202.1.1,mountvers=3,mountport=41576,mountproto=tcp,local_lock=none,addr=198.202.1.1 0 0


Actual Result:
But instead in /proc/self/mounts I get (notice the trailing slash):
nfsserver:/srv/ubuntu-32/ /mnt/ubuntu-32 nfs ro,nosuid,nodev,noatime,vers=3,rsize=32768,wsize=32768,namlen=255,soft,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=198.202.1.1,mountvers=3,mountport=41576,mountproto=tcp,local_lock=none,addr=198.202.1.1 0 0


Rammifications:
This simple change has a lot of implications because lots of things parse
/etc/fstab and /proc/self/mounts, for example system configuration tools
and mount.nfs and umount.nfs.

If you use the former convention and try to umount an export on a newer
kernel it will fail:

user@hostname:/proc/self$ sudo umount.nfs nfsserver:/srv/ubuntu-32
umount.nfs: nfsserver:/srv/ubuntu-32: not found

And if you run "sudo mount -va", mount will not recognize that the fstab mounts
have already been mounted; mounting all mounts twice on the same mount point.
This quickly gets messy.

If there is a new convention to display the trailing slash, we need to update
our tools to handle this change. If there is not a new convention, I'd argue
this is a bug.

So is this a new convention or not? What is the appropriate way for Debian to move forward?

Thanks,
Chris Hiestand

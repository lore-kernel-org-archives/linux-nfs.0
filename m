Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:35670 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965466AbbBCAZU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 19:25:20 -0500
Received: from spindle.srvr.nix (nix@spindle.srvr.nix [192.168.14.15])
	by mail.esperi.org.uk (8.14.9/8.14.8) with ESMTP id t130PIDj003980
	for <linux-nfs@vger.kernel.org>; Tue, 3 Feb 2015 00:25:18 GMT
From: Nix <nix@esperi.org.uk>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: what on earth is going on here? paths above mountpoints turn into "(unreachable)"
Date: Tue, 03 Feb 2015 00:25:18 +0000
Message-ID: <87iofju9ht.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is with client and server both running NFSv3 on 3.18.4 (an upgrade
to .5 is on the cards soon). (This is *not* the same client I've been
reporting the panic on, though the server is the same, and this client
too has been seeing the panic. Not that that's relevant, since that's a
bug on shutdown, and this isn't. Indeed this may not be a bug at all,
but it's new behaviour with 3.18.x, and it breaks programs, and it's
weird.)

The server says (for this client):

/usr/archive -fsid=25,root_squash,async,subtree_check,crossmnt mutilate(rw,root_squash,insecure)
/usr/archive/series -fsid=29,root_squash,async,subtree_check mutilate(rw,root_squash,insecure)

The client says:

package.srvr.nix:/usr/archive /usr/archive nfs defaults,rw

(i.e. relying on the crossmnt, though I have just changed this to
explicitly mount both mount points, while preserving the crossmnt on the
parent for the sake of other clients that can't mount both because
they're using libnfs and need to follow symlinks from other places under
/usr/archive/ into /usr/archive/series, and the software is too stupid
to understand that there might be more than one mount point involved.)

I'm seeing this bizarre output after a long delay (memory pressure not
required: vapoursynth, which was running here, is using a couple of gig
out of 16GiB, and the machine has 12GiB in buffers/cache):

FileNotFoundError: [Errno 2] No such file or directory: '(unreachable)/Orphan-Black/1'
Failed to retrieve output node. Invalid index specified?
pipe:: Invalid data found when processing input
nix@mutilate 45 .../Orphan-Black/1% pwd -P
/usr/archive/series/Orphan-Black/1
# Well, doesn't this cwd look weird.
nix@mutilate 46 ...//1% ls -l /proc/self/cwd
lrwxrwxrwx 1 nix users 0 Feb  2 23:28 /proc/self/cwd -> /Orphan-Black/1
nix@mutilate 49 .../Orphan-Black/1% ls -id .
624194 .
# Try going out of the directory and back into it again.
nix@mutilate 50 .../Orphan-Black/1% cd -
/tmp
nix@mutilate 51 /tmp% cd -
/usr/archive/series/Orphan-Black/1
# Same inode, but now the cwd is valid!
nix@mutilate 52 .../Orphan-Black/1% ls -id .
624194 .
nix@mutilate 54 .../Orphan-Black/1% ls -l /proc/self/cwd
lrwxrwxrwx 1 nix users 0 Feb  2 23:28 /proc/self/cwd -> /usr/archive/series/Orphan-Black/1

So something about the mountpoint is expiring away, as if it had been
umount -l'ed. No automounter of any kind is running, and (obviously) it
*wasn't* umount -l'ed.

I guess by tomorrow I'll know if this is crossmnt-related, at least... I
know crossmnt is considered bad and evil: is this sort of thing why?

The filesystem being NFS-exported is on a USB-attached disk that spins
down when not in use, but I'd not expect that to do anything other than
cause delays on first access (and indeed even if I turn off spindown
this still happens, even though the filesystem is perfectly accessible,
from the server and indeed from the client: it's just... disconnected,
which seems to greatly annoy a lot of programs.)

If it happens again I'll see if I can arrange to have two processes, one
with a cwd in the full path, one with a cwd in the truncated one. That
at least will tell us whether this is some sort of expiry thing attached
to one mountpoint, and going back into it is de-expiring it for all
users under that mountpoint, or whether we really are seeing a new mount
here, somehow (how, without mount(2) ever being called?!).

-- 
NULL && (void)

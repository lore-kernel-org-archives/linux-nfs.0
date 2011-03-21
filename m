Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36798 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752425Ab1CUSTQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2011 14:19:16 -0400
Date: Mon, 21 Mar 2011 14:19:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dennis Jacobfeuerborn <dennisml@conversis.de>
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: bind mounts, crossmnt and multi client nfsv3
Message-ID: <20110321181913.GA472@fieldses.org>
References: <4D86B6F2.1070004@conversis.de>
 <20110321140923.5a618d89@notabene.brown>
 <4D874419.5030303@conversis.de>
 <20110321172530.GA32359@fieldses.org>
 <4D87908E.1020107@conversis.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D87908E.1020107@conversis.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 21, 2011 at 06:53:18PM +0100, Dennis Jacobfeuerborn wrote:
> On 03/21/2011 06:25 PM, J. Bruce Fields wrote:
> >On Mon, Mar 21, 2011 at 01:27:05PM +0100, Dennis Jacobfeuerborn wrote:
> >>On 03/21/2011 04:09 AM, NeilBrown wrote:
> >>>On Mon, 21 Mar 2011 03:24:50 +0100 Dennis Jacobfeuerborn
> >>><d.jacobfeuerborn@conversis.de>   wrote:
> >>>
> >>>>Hi,
> >>>>I have a storage system that is exporting many directories to multiple
> >>>>clients resulting in a lot of mountpoints (156) on each client. What I'm
> >>>>trying to do is to create a single directory on the server and then use
> >>>>mount --bind to mount all the different directories (which are stored on
> >>>>different LVM volumes) into this single export directory and finally export
> >>>>this directory to the clients.
> >>>>Now the exports man-page mentions the crossmnt option but it also mentions
> >>>>that it cannot be used if I want to export the directory to multiple
> >>>>clients. Is there another way to accomplish something like this?
> >>>>
> >>>
> >>>Just export the top directory with 'crossmnt' - it should work fine.
> >>>
> >>>The 'multiple clients' thing only affects 'nohide' and I think it only
> >>>affected it back in 2.4 days.
> >>>Lots changed with 2.6, but maybe not enough of the man page changed :-(
> >>>
> >>>So try with 'crossmnt' and if it doesn't work, then come back with details.
> >>
> >>I've tried this now but it doesn't seem to work. This is the setup so far:
> >>
> >>===========
> >>
> >>On the server I've created the bind mounts like this:
> >>
> >>/mnt/vg0/vol01/country/de/a on /exports/country/de/a type none (rw,bind)
> >>/mnt/vg0/vol03/country/de/b on /exports/country/de/b type none (rw,bind)
> >>...
> >>
> >>Then I put the following line in /etc/exports:
> >>/exports 192.168.0.0/255.255.255.0(rw,anonuid=96,anongid=96,secure,no_root_squash,wdelay,sync,crossmnt,no_subtree_check)
> >>
> >>additionally these exports exist for each volume:
> >>/mnt/vg0/vol01/country 213.131.252.0/255.255.255.0(rw,anonuid=96,anongid=96,secure,no_root_squash,wdelay,sync)
> >
> >I'm a bit confused by the paths and ip blocks:
> >
> >	- You want to export the path that the client sees
> >	  (/exports/country/whatever), not the original path
> >	  (/mnt/vg0/...).
> >	- If you expect clients to be able to traverse from /exports/ to
> >	  filesystems underneath, then you'd want to make sure /exports/
> >	  is exported to anything that the filesystems underneath are.
> 
> The /mnt/vg0/volXX exports are currently used to export each
> filesystem containing letters individually. On the client I then
> mount each letter individually which means access to each mountpoint
> doesn't have to traverse filesystem boundaries on the server but it
> also means I end up with 156 individual mountpoints which is a pain
> to deal with. I had to write a script that runs a loop mounting 5
> letters then waiting 30 seconds then mount the next 5 letters etc.
> If I try to mount these in one go about 10 mounts work fine but then
> I only get errors. Apparently the server can only handle so many
> mounts in a certain timeframe (socket timeouts?)

Might be interesting to pin that problem down.  I wonder if "insecure"
would help?

> That's why I'm aiming for consolidating the letters on the server
> using bind mounts and then just mount the country directories
> leaving me with 6 mountpoints per client which would be *much*
> easier to handle.

Oh, so you're actually exporting each filesystem *twice*, in two
different places?

I think the server can deal with that.  But probably only if the two
filesystems have the same export options.  (You've got crossmnt and
no_subtree_check set on one but not the other.)

Wait, and looks like you're also bind mounting *subdirectories* of
filesystems instead of whole filesystems.  I'm not sure the server will
handle that the way you'd expect.

Is there any reason you can't just bind-mount all of /mnt/vg0/vol01/, or
whatever, to the same path?

> The 192 IP range was a mistake and that should be the same 213 range
> as the /exports export. If I can get this working then I plan to
> eliminate the individual /mnt/vg0/... exports if they are not
> needed.
> 
> >But actually you should only need the first /exports entry; filesystems
> >underneath should inherit export options from the parent.
> 
> This is what /var/lib/nfs/etab says for /exports after an exportfs -r:
> /exports 213.131.252.0/255.255.255.0(rw,sync,wdelay,hide,crossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,mapping=identity,anonuid=96,anongid=96)
> 
> When I mount this I can see the proper subdirectories until I get to
> the bind mounted letter directories which have their expected
> contents on the server but appear empty on the client.

Note also NFSv2/v3 clients aren't necessarily equipped to deal with
filesystem boundaries, and some applications may be confused by seeing
what look like files with the same inode number on the same filesystem
that are actually different files.

--b.

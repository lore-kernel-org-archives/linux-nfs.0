Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49153 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753552Ab3LSRJ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Dec 2013 12:09:28 -0500
Date: Thu, 19 Dec 2013 12:09:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sander Klein <roedie@roedie.nl>
Cc: linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org,
        util-linux@vger.kernel.org
Subject: Re: rpc.mountd high cpu usage
Message-ID: <20131219170927.GA3013@fieldses.org>
References: <889b64df295ba04d47f941762ebe0bac@roedie.nl>
 <20131212154642.GA11521@fieldses.org>
 <3e92cb841fa81d6a16f3d471cdd8bb20@roedie.nl>
 <20131212212213.GC13467@fieldses.org>
 <c50ec8735833f8c05a351928ae48b6df@roedie.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <c50ec8735833f8c05a351928ae48b6df@roedie.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 13, 2013 at 08:32:56PM +0100, Sander Klein wrote:
> On , J. Bruce Fields wrote:
> >>>I think what happens is that exportfs flushes the kernel's export cache
> >>>at which point every use of an uncached export triggers an upcall to
> >>>mountd.  That upcall is probably visible in the strace as a read of a
> >>>file descriptor associated with /proc/net/sunrpc/nfsd.fh/content.
> >>>
> >>>That upcall is handled by nfs-utils/utils/mountd/cache.c:nfsd_fh(),
> >>>which is given a filehandle fragment identifying the filesystem in
> >>>question and has to match it to an export.
> >>>
> >>>That's done by match_fsid().  Which does do a stat of the export path,
> >>>but not of all the devices....  That's probably happening in one of the
> >>>libblkid calls in uuid_by_path()?  I wonder if there's something wrong
> >>>with libblkid configuration or with the way we're using it?
> >>
> >>Is there any way I can help getting this fixed? My coding skills are
> >>limited but I am very willing to help in any way I can.
> >
> >I wonder if ltrace could help determine if libblkid is where most of
> >those stat's are coming from (and if so, which calls)?
> >
> >May also be worth reading up on libblkid (man libblkid, etc.) and
> >checking your configuration to make sure there's nothing obvious broken
> >there.  (If so, maybe the libblkid commandline tools would exhibit the
> >same problem?)
> 
> I didn't have any config in /etc/blkid.conf and the manpage says it
> will use EVALUATE=udev,scan which in fact scans through all the
> /dev/disk/by-* dirs and parses the /proc/partitions. I put
> 'EVALUATE=scan' in /etc/blkid.conf but that doesn't help. I
> restarted anything NFS related...
> 
> I also attached ltrace to the rpc.mountd process. The output of the
> trace is at http://pastebin.com/ika1Vetq . I'm not sure what I'm
> looking for. The ltrace is done on a server with only 10 harddisks
> but the strace showed the same behavour of newfstatat-ing every disk
> in a lot of ways.

Hm.  I *think* that those SYS_262's are the newfstatat's.  And it looks
like they happen as part of the implementation of blkid_devno_to_devname
(just because you see that call start above the SYS_262's and return
only after).

That is indeed called from utils/mountd/cache.c:get_uuid_blkdev().

So libblkid is mapping device numbers to paths by stat'ing lots of stuff
under /dev.

I'm not sure what to do about that.... Cc'ing util-linux in case they
can help.

--b.

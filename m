Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48596 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642Ab3LLVWO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Dec 2013 16:22:14 -0500
Date: Thu, 12 Dec 2013 16:22:13 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sander Klein <roedie@roedie.nl>
Cc: linux-nfs@vger.kernel.org
Subject: Re: rpc.mountd high cpu usage
Message-ID: <20131212212213.GC13467@fieldses.org>
References: <889b64df295ba04d47f941762ebe0bac@roedie.nl>
 <20131212154642.GA11521@fieldses.org>
 <3e92cb841fa81d6a16f3d471cdd8bb20@roedie.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3e92cb841fa81d6a16f3d471cdd8bb20@roedie.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 12, 2013 at 05:42:44PM +0100, Sander Klein wrote:
> On , J. Bruce Fields wrote:
> >That sounds like somewhat of an extreme setup, and I suspect the
> >current
> >behavior is by design, but I agree that we should fix it.  I'm not
> >volunteering for now....
> 
> Ow dear, I never thought that this would classified as an extreme
> setup :-) .

Eh, maybe it's not.

> >I think what happens is that exportfs flushes the kernel's export cache
> >at which point every use of an uncached export triggers an upcall to
> >mountd.  That upcall is probably visible in the strace as a read of a
> >file descriptor associated with /proc/net/sunrpc/nfsd.fh/content.
> >
> >That upcall is handled by nfs-utils/utils/mountd/cache.c:nfsd_fh(),
> >which is given a filehandle fragment identifying the filesystem in
> >question and has to match it to an export.
> >
> >That's done by match_fsid().  Which does do a stat of the export path,
> >but not of all the devices....  That's probably happening in one of the
> >libblkid calls in uuid_by_path()?  I wonder if there's something wrong
> >with libblkid configuration or with the way we're using it?
> 
> Is there any way I can help getting this fixed? My coding skills are
> limited but I am very willing to help in any way I can.

I wonder if ltrace could help determine if libblkid is where most of
those stat's are coming from (and if so, which calls)?

May also be worth reading up on libblkid (man libblkid, etc.) and
checking your configuration to make sure there's nothing obvious broken
there.  (If so, maybe the libblkid commandline tools would exhibit the
same problem?)

--b.

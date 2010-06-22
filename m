From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Improve support for exporting btrfs subvolumes.
Date: Tue, 22 Jun 2010 16:16:28 -0400
Message-ID: <4C211A1C.4010701@RedHat.com>
References: <19481.43625.476833.275104@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754548Ab0FVUQf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jun 2010 16:16:35 -0400
In-Reply-To: <19481.43625.476833.275104-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/17/2010 12:54 AM, Neil Brown wrote:
> 
> If you export two subvolumes of a btrfs filesystem, they will both be
> given the same uuid so lookups will be confused.
> blkid cannot differentiate the two, so we must use the fsid from
> statfs64 to identify the filesystem.
> 
> We cannot tell if blkid or statfs is best without knowing internal
> details of the filesystem in question, so we need to encode specific
> knowledge of btrfs in mountd.  This is unfortunate.
> 
> To ensure smooth handling of this and possible future changes in uuid
> generation, we add infrastructure for multiple different uuids to be
> recognised on old filehandles, but only the preferred on is used on
> new filehandles.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> --
> This is a substantially revised version of a patch I posted a while
> ago.
> I tried to find a way to do it would hard coding knowledge of btrfs in
> nfs-utils, but it isn't possible.  For some filesystems, f_fsid is
> best, for some it is worst.  No way to tell the difference.
> 
> This patch add infrastructure so that if we find a better way to get a
> good uuid (e.g. a new syscall), we can slot it in for new filehandles,
> but old filehandles using the old uuid will still work.
> 
> I believe this is ready for inclusion upstream.

Committed...

steved.


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.pictura-hosting.nl ([195.93.224.144]:42045 "EHLO
	mail.pictura-dp.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523Ab3LLQnH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Dec 2013 11:43:07 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Thu, 12 Dec 2013 17:42:44 +0100
From: Sander Klein <roedie@roedie.nl>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: rpc.mountd high cpu usage
In-Reply-To: <20131212154642.GA11521@fieldses.org>
References: <889b64df295ba04d47f941762ebe0bac@roedie.nl>
 <20131212154642.GA11521@fieldses.org>
Message-ID: <3e92cb841fa81d6a16f3d471cdd8bb20@roedie.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On , J. Bruce Fields wrote:
> That sounds like somewhat of an extreme setup, and I suspect the 
> current
> behavior is by design, but I agree that we should fix it.  I'm not
> volunteering for now....

Ow dear, I never thought that this would classified as an extreme setup 
:-) .

> I think what happens is that exportfs flushes the kernel's export cache
> at which point every use of an uncached export triggers an upcall to
> mountd.  That upcall is probably visible in the strace as a read of a
> file descriptor associated with /proc/net/sunrpc/nfsd.fh/content.
> 
> That upcall is handled by nfs-utils/utils/mountd/cache.c:nfsd_fh(),
> which is given a filehandle fragment identifying the filesystem in
> question and has to match it to an export.
> 
> That's done by match_fsid().  Which does do a stat of the export path,
> but not of all the devices....  That's probably happening in one of the
> libblkid calls in uuid_by_path()?  I wonder if there's something wrong
> with libblkid configuration or with the way we're using it?

Is there any way I can help getting this fixed? My coding skills are 
limited but I am very willing to help in any way I can.

Greets,

Sander

From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Different options for subdir? Possible?
Date: Mon, 17 May 2010 16:49:47 -0400
Message-ID: <20100517204947.GC5232@fieldses.org>
References: <20100515153104.51f5e4ab@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Pierre Ossman <pierre-list-vCPtPcF4ZGuHXe+LvDLADg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39946 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755761Ab0EQUts (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 May 2010 16:49:48 -0400
In-Reply-To: <20100515153104.51f5e4ab-OhHrUh4vRMS8I+09wXhka4dd74u8MsAO@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 15, 2010 at 03:31:04PM +0200, Pierre Ossman wrote:
> I'd like to export the filesystem /exports as ro, but the
> subdir /exports/dump as rw. I can't seem to get it to work though, so
> before I start digging deeper I figured I might ask if this is even
> possible? :)

If the "dump" subdirectory is a subdirectory of the same filesystem (not
a mountpoint), and if you're using NFSv4 (or v2/v3 with crossmnt), the
client will continue to use the export options on the parent directory.

Also, note that it's relatively easy for someone with access to the
network to treat all of /exports as rw.

In general, export points that aren't mountpoints are not usually a good
idea.

--b.

> 
> I tried this in /etc/exports:
> 
> /exports/dump	1.2.3.4(rw)
> /exports	1.2.3.4(ro)
> 
> Rgds
> -- 
>      -- Pierre Ossman
> 
>   WARNING: This correspondence is being monitored by FRA, a
>   Swedish intelligence agency. Make sure your server uses
>   encryption for SMTP traffic and consider using PGP for
>   end-to-end encryption.



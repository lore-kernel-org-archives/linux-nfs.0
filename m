Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51032 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754784Ab0ECS4v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 May 2010 14:56:51 -0400
Date: Mon, 3 May 2010 14:56:50 -0400
To: maillists0@gmail.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: Proxy
Message-ID: <20100503185650.GA9864@fieldses.org>
References: <l2wdc64e7231005030953xb72ad73az3f883167a1a637c8@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <l2wdc64e7231005030953xb72ad73az3f883167a1a637c8@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 03, 2010 at 12:53:15PM -0400, maillists0@gmail.com wrote:
> With NFS4's support for referrals and Kerberos, it seems like the
> original reasons to prevent re-exporting of an NFS share might no
> longer exist. With fs-proxy making its way into the mainline kernel
> and things like cachefilesd, there are also very good reasons to allow
> it. A proxy server with a persistent cache could give the ability to
> robustly use shares across a WAN or do failover pairs with no need for
> more complex replication. Speaking as an end-user, this would be very
> desirable.
> 
> I see that others have implemented proxies with user-space NFS, which
> seems reasonable but not optimal. What is the obstacle to allowing
> re-exports with the standard nfs implentation? Is it possible at the
> moment to patch a kernel to make this work? Anyone have experience
> with it? Any input is appreciated.

It's probably possible, but some kernel hacking would be required.

Off the top of my head:

	- filehandles: you probably can't pass your server's filehandles
	  unchanged back to your client.  At a minimum you'd want to add
	  a header allowing you to distinguish filehandles for the
	  different filesystems you export.  What if you get a
	  filehandle from the server that's already at the protocol's
	  maximum size?  Are you going to try to maintain your own
	  persistent mapping of filehandles, and if so, is it possible
	  to do that with reasonable performance?
	- what do you do if your server takes a really long time to
	  answer a request?  Or stops responding completely?

--b.

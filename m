Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56399 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841Ab0DOSEb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Apr 2010 14:04:31 -0400
Date: Thu, 15 Apr 2010 14:04:31 -0400
To: "Michael O'Donnell" <modonnell@wsi.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS stops responding
Message-ID: <20100415180431.GA13717@fieldses.org>
References: <4BC62E38.3010704@wsi.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4BC62E38.3010704@wsi.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Apr 14, 2010 at 05:06:00PM -0400, Michael O'Donnell wrote:
> When I display the client traffic log file with Wireshark, it (apparently)
> confirms that the client did indeed wait a while and then (apparently)
> retransmitted the NFS request.  The weird thing is that Wireshark analysis
> of corresponding traffic on the server shows the first request coming in
> and being replied to immediately, then we later see the retransmitted
> request arrive and it, too, is promptly processed and the response goes
> out immediately.  So, if I'm reading these tea leaves properly it's as if
> that client lost the ability to recognize the reply to that request.  [?!]
>
> But, then, how could it be that all 3 machines seem to get into this state
> at more or less the same time?  and why would unmounting and remounting
> all NFS filesystems then "fix" it?   Aaaiiieeee!!!

I don't know, I haven't seen that.

> I know of no reasons in principle why two machines can't simultaneously
> act as NFS clients and NFS servers - are there any?  AFAIK the two
> subsystems are separate and have no direct dependencies or interactions;
> does anybody know otherwise?

Well, they can compete for common resources (like memory), and in that
case there are at least theoretical deadlocks.  (A's server can't
proceed until gets some memory, but first it needs A's client to flush
some dirty pages, which depends on server B processing some request,...
etc.)

I don't know how to actually reproduce such a deadlock, but I wouldn't
recommend depending on its absence, either.

--b.

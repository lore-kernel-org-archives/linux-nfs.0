From: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Subject: Re: NFS hangs with 2.6.25/2.6.26 despite server being reachable
Date: Thu, 24 Jul 2008 03:03:06 -0700
Message-ID: <20080724100306.GA26872@zoy.org>
References: <20080716054053.GE6159@zoy.org> <20080716191553.GG20298@fieldses.org> <20080718060405.GD12135@zoy.org> <20080721021408.GA7949@zoy.org> <20080723215210.GB29065@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.lespinasse.org ([64.142.28.226]:41663 "EHLO
	server.lespinasse.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbYGXKDH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jul 2008 06:03:07 -0400
In-Reply-To: <20080723215210.GB29065@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 23, 2008 at 05:52:10PM -0400, J. Bruce Fields wrote:
> Oh, sorry, I think I overlooked the note in your original message that
> this happened after suspend-to-ram.  That's interesting!  You really
> need someone with more experience debugging the rpc client.... It might
> also be worth turning on rpc debugging during the hang just to get the
> dump of rpc task states.  (So
> 
> 	echo 0 >/proc/sys/sunrpc/rpc_debug
> 
> and capture the first table it dumps to the log.  Or Trond or Chuck
> might have some better idea.)

Since it does not look like we'll solve this overnight, I opened
bug 11154 to track this. Please feel free to suggest what to try there...

Thanks,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

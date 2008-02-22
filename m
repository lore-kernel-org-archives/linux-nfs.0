From: Neil Brown <neilb@suse.de>
Subject: Re: mountd prevents spindown of non-exported disk
Date: Fri, 22 Feb 2008 11:25:53 +1100
Message-ID: <18366.5777.25957.73691@notabene.brown>
References: <47BCA119.2030404@foo-lounge.de>
	<18364.64328.189954.417159@notabene.brown>
	<47BD5DFA.8080200@foo-lounge.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Timo Reimann <mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:56508 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758454AbYBVAZr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 19:25:47 -0500
In-Reply-To: message from Timo Reimann on Thursday February 21
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday February 21, mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org wrote:
> > 
> > You could always build your own nfs-utils and configure with
> > --without-uuid.
> > 
> > Not an ideal solution...
> 
> What would be the downside of that solution? I suppose NFS would keep on
> working even if I disabled that switch, but you gave the impression
> there was some (major) drawback.
> 

The fact that you have to compile your own tools rather than just use
what the distro provides is always a bit of a bore.

Also, if you change the server to stop using UUIDs, then any clients
which have the filesystem mounted will need to remount as the old
mount will become stale.

So it isn't a major problem, but nor is it an ideal solution.

NeilBrown

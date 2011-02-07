Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47454 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754744Ab1BGVTS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Feb 2011 16:19:18 -0500
Date: Mon, 7 Feb 2011 16:19:17 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Haynes <tdh@excfb.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Debugging mount failure with netgroup
Message-ID: <20110207211917.GA3853@fieldses.org>
References: <20110207195609.GA13225@adept.internal.excfb.com>
 <20110207201202.GA3055@fieldses.org>
 <20110207205306.GA13731@adept.internal.excfb.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110207205306.GA13731@adept.internal.excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 07, 2011 at 02:53:06PM -0600, Tom Haynes wrote:
> I did google and did not find much on netgroups - but I did find
> a bunch on "unmatched host".
> 
> It seems to be black magic from some of the answers.
> 
> And I agree:
> 
> 1) Modified the export:
> [root@adept /]# more /etc/exports 
> /fooper   @adeptya(rw,insecure,no_root_squash,sync)

So it was probably the "insecure"?

Are we returning the right error to the mount client in that case?

And I suppose the logged error should be more helpful.  I'm not really
sure mountd should be logging every mount failure by default, but if you
request it, it should at be able to tell you the reason for the failure.

--b.

> 
> 2) Did other mumbo-jumbo
> 
> 3) Really, really did not want to reboot.
> 
> 4) service nfs stop ; exportfs ; service nfs start
> 
> And that last one worked!
> 
> Feb  7 14:44:31 adept mountd[13712]: Received MNT3(/fooper) request from 192.168.2.105
> Feb  7 14:44:31 adept mountd[13712]: authenticated mount request from wont.internal.excfb.com:972 for /fooper (/fooper)
> Feb  7 14:44:31 adept mountd[13712]: nfsd_fh: inbuf '@adeptya 7 \x0100060000000000a9a3be796f4c43878b99ea75025e5384'
> Feb  7 14:44:31 adept mountd[13712]: nfsd_fh: found 0x20da950 path /fooper
> 
> Thanks
> 
> > 
> > --b.
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Tom Haynes
> ex-cfb

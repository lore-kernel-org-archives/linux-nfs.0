Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39417 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753487Ab1BFTbQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 6 Feb 2011 14:31:16 -0500
Date: Sun, 6 Feb 2011 14:31:14 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: David Brodbeck <brodbd@uw.edu>
Cc: George Spelvin <linux@horizon.com>, linux-nfs@vger.kernel.org,
        nix@esperi.org.uk
Subject: Re: persistent, quasi-random -ESTALE at mount time
Message-ID: <20110206193114.GB14850@fieldses.org>
References: <20110203034844.GA30641@fieldses.org>
 <20110203042814.6364.qmail@science.horizon.com>
 <AANLkTinUMeTowsWtxFm+Ga_ChVztWuUNe6na_Tq+F2==@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTinUMeTowsWtxFm+Ga_ChVztWuUNe6na_Tq+F2==@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 03, 2011 at 11:16:29AM -0800, David Brodbeck wrote:
> On Wed, Feb 2, 2011 at 8:28 PM, George Spelvin <linux@horizon.com> wrote:
> 
> > I don't ever remember a Linux-linux nfs mount surviving a server
> > reboot.
> >
> 
> I do it semi-regularly and it *usually* works...but I never reboot the
> server unless I'm prepared to reboot hung clients, just in case.
> 
> Actually, I've seen more problems with Solaris-Linux NFSv4 mounts.  For a
> while there was a pretty good chance that rebooting a server would result in
> state recovery failure loops on the client.  I see less of that lately, but
> I'm also doing fewer server reboots...

There have been some recovery bugs fixed; if you know of any more,
details would be welcomed.

--b.

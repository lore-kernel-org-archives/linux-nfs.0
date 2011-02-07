Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao101.cox.net ([68.230.240.7]:50296 "EHLO
	eastrmmtao101.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754631Ab1BGXUq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Feb 2011 18:20:46 -0500
Date: Mon, 7 Feb 2011 17:21:10 -0600
From: Tom Haynes <tdh@excfb.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Debugging mount failure with netgroup
Message-ID: <20110207232110.GB15778@adept.internal.excfb.com>
References: <20110207195609.GA13225@adept.internal.excfb.com>
 <20110207201202.GA3055@fieldses.org>
 <20110207205306.GA13731@adept.internal.excfb.com>
 <20110207211917.GA3853@fieldses.org>
 <20110207215344.GA15778@adept.internal.excfb.com>
 <20110207215935.GB3853@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110207215935.GB3853@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 07, 2011 at 04:59:35PM -0500, J. Bruce Fields wrote:
> 
> Changes to /etc/exports aren't automatically detected, so you need a
> server restart or an exportfs -ra after any change.

Yep:

exportfs -au  # unload old rules
exportfs      # verify it is empty
exportfs -a   # load it up
exportfs      # verify it loaded

So I would have expected it to have reloaded.


> 
> OK, so maybe the problem was just that mountd never found out about your
> original /etc/exports file?

That wouldn't explain why it has stopped working now.

Neither the exportfs commands above nor a service nfs stop/start
yields a working mount from the client.

Restarting nfsd with an export of:

[root@adept internal.excfb.com]# exportfs
/fooper       	192.168.2.0/255.255.255.0
[root@adept internal.excfb.com]# uname -a
Linux adept.internal.excfb.com 2.6.34.7-66.fc13.i686.PAE #1 SMP Wed Dec 15 07:21:49 UTC 2010 i686 i686 i386 GNU/Linux

Does yield a mount.

> 
> --b.
> 

-- 
Tom Haynes
ex-cfb

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay0137.hostedemail.com ([216.40.44.137]:34135 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750966Ab3IZPhb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 11:37:31 -0400
Received: from smtprelay.hostedemail.com (ff-bigip1 [10.5.19.254])
	by smtpgrave08.hostedemail.com (Postfix) with ESMTP id C3CBE212ADF
	for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 15:31:07 +0000 (UTC)
Message-ID: <1380209415.17366.66.camel@joe-AO722>
Subject: Re: [PATCH 3/4] SunRPC: Use no_printk() for the null dprintk() and
 dfprintk()
From: Joe Perches <joe@perches.com>
To: David Howells <dhowells@redhat.com>
Cc: bfields@fieldses.org, Trond.Myklebust@netapp.com, olof@lixom.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Sep 2013 08:30:15 -0700
In-Reply-To: <20130926144525.29424.11130.stgit@warthog.procyon.org.uk>
References: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
	 <20130926144525.29424.11130.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-09-26 at 15:45 +0100, David Howells wrote:
> Use no_printk() for the null dprintk() and dfprintk() so that the compiler
> doesn't complain about unused variables for stuff that's just printed.

no_printk doesn't prevent any argument side-effects
from being optimized away by the compiler.

ie:
	dprintk("%d", func())
func is now always called when before it wasn't.

Are there any side-effects?

btw: Using

#define dprintk(fmt, ...)
do {
	if (0)
		printk(fmt, ##__VA_ARGS__);
} while (0)

does away with side-effects.



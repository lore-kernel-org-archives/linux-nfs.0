From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 01/11] svcrdma: Add a type for keeping NFS RPC mapping
Date: Tue, 24 Jun 2008 16:38:54 -0400
Message-ID: <1214339935.7156.50.camel@localhost>
References: <12120836962076-git-send-email-tom@opengridcomputing.com>
	 <12120836962324-git-send-email-tom@opengridcomputing.com>
	 <20080616194858.GA29446@fieldses.org> <485D2CEF.404@opengridcomputing.com>
	 <20080623182707.GC24373@fieldses.org>
	 <486062CD.6010800@opengridcomputing.com>
	 <20080624195838.GE15786@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tom Tucker <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:55814 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752353AbYFXUjB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jun 2008 16:39:01 -0400
In-Reply-To: <20080624195838.GE15786@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-06-24 at 15:58 -0400, J. Bruce Fields wrote:
> My understanding is that it's A--e.g. checkpatch.pl has a dumb regex
> that just checks for these assignments and whines about them however
> they're used.
> 
> Google doesn't find me any more detailed discussion of the policy.

We had that discussion about 10 years ago.

What followed was a general purge of all zero initialisations of global
and static variables in the kernel, and the official policy is that
initialising those variables is wrong, and should _not_ be done.

The reason is that BSS is automatically zeroed out, and so adding an
initialiser causes unnecessary code bloat and slows down the boot
process.

Trond


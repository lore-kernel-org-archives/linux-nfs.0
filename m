Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:56723 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752675Ab1AXVKx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jan 2011 16:10:53 -0500
Date: Mon, 24 Jan 2011 16:10:38 -0500
From: Nick Bowler <nbowler@elliptictech.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@netapp.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NLM: Fix "kernel BUG at fs/lockd/host.c:417!" or
 ".../host.c:283!"
Message-ID: <20110124211038.GA22199@elliptictech.com>
References: <20110124204332.1878.35846.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110124204332.1878.35846.stgit@matisse.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-01-24 15:50 -0500, Chuck Lever wrote:
> Nick Bowler <nbowler@elliptictech.com> reports:
> 
> > We were just having some NFS server troubles, and my client machine
> > running 2.6.38-rc1+ (specifically, commit 2b1caf6ed7b888c95) crashed
> > hard (syslog output appended to this mail).
[...]
> I was able to reproduce this BUG on my client running 2.6.38-rc2
> from earlier today.  Here is a proposed fix.  I can't reproduce the
> BUG with this patch applied.
> 
> However, my reproducer hit the BUG in nlmsvc_release_host().  Nick hit
> roughly the same BUG in nlmclnt_release_host(), which suggests his
> "client" was also acting as a server.

Yeah, there are NFS exports on the client machine as well; although
as nobody had them mounted (and due to the timing of the crash) I hadn't
considered them.

> The symptoms are similar enough that I believe this patch should be
> sufficient to address both cases.

I'll try the patch, but since I don't know how to reproduce the failure
(rebooting the server just to see if it crashes again isn't an option),
I'll have to take your word for it.

Thanks,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

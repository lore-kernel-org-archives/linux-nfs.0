Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:58708 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753610Ab1AXQyn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jan 2011 11:54:43 -0500
Date: Mon, 24 Jan 2011 11:54:41 -0500
From: Nick Bowler <nbowler@elliptictech.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: possible regression: BUG in client lockd with server reboot.
Message-ID: <20110124165441.GA14255@elliptictech.com>
References: <20110124144107.GA3718@elliptictech.com>
 <4707872F-6CC4-477D-AE0B-A7DCEEF29ABF@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4707872F-6CC4-477D-AE0B-A7DCEEF29ABF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-01-24 11:08 -0500, Chuck Lever wrote:
> Nick-
> 
> On Jan 24, 2011, at 9:41 AM, Nick Bowler wrote:
> 
> > We were just having some NFS server troubles, and my client machine
> > running 2.6.38-rc1+ (specifically, commit 2b1caf6ed7b888c95) crashed
> > hard (syslog output appended to this mail).
> 
> I don't seem to have 2b1caf6e.  Can you post the short description?

commit 2b1caf6ed7b888c95a1909d343799672731651a5
Merge: d551d81 bd924e8
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Thu Jan 20 18:30:37 2011 -0800

    Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip

> host.c:283 is " BUG_ON(!list_empty(&host->h_lockowners));" in my tree.
> Can you confirm this is the same for you?

Yes, it is.

> I'll have a look.

Great, thanks!

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

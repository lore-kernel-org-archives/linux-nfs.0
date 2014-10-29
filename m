Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail05.adl6.internode.on.net ([150.101.137.143]:14668 "EHLO
	ipmail05.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757287AbaJ2XeP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Oct 2014 19:34:15 -0400
Date: Thu, 30 Oct 2014 10:33:31 +1100
From: Dave Chinner <david@fromorbit.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: fstests@vger.kernel.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] common:  Fixes for testing NFS over IPv6
Message-ID: <20141029233331.GO16186@dastard>
References: <1414611127-14246-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1414611127-14246-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 29, 2014 at 03:32:07PM -0400, Anna Schumaker wrote:
> When testing NFS over IPv6, the user will set a $TEST_DEV of the form
> [fe80::42]:/export.  The use of square brackets surrounding the IPv6
> address is an accepted convention, but grep and awk think that our IPv6
> address is actually a regex and tries to evaluate it instead.  The
> result is that xfstests reports our filesystem "is busy or already
> mounted".
> 
> This patch fixes the IPv6 problem by telling awk and grep to treat
> $TEST_DEV as a fixed string rather than a regex.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Seems sensible, but it needs comments so that when someone copies
the code they know why it's using these sorts of matches.

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

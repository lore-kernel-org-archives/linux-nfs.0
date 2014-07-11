Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:41084 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751520AbaGKRbf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2014 13:31:35 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Jeff Layton'" <jlayton@primarydata.com>, <bfields@fieldses.org>
Cc: <hch@infradead.org>, <linux-nfs@vger.kernel.org>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com> <1405015655-12469-11-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405015655-12469-11-git-send-email-jlayton@primarydata.com>
Subject: RE: [PATCH 10/11] nfsd: make deny mode enforcement more efficient and close races in it
Date: Fri, 11 Jul 2014 10:31:26 -0700
Message-ID: <03f901cf9d2d$f23c21f0$d6b465d0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> The current enforcement of deny modes is both inefficient and scattered
> across several places, which makes it hard to guarantee atomicity. The
> inefficiency is a problem now, and the lack of atomicity will mean races
once
> the client_mutex is removed.
> 
> First, we address the inefficiency. We have to track deny modes on a per-
> stateid basis to ensure that open downgrades are sane, but when the server
> goes to enforce them it has to walk the entire list of stateids and check
> against each one.
> 
> Instead of doing that, maintain a per-nfs4_file deny mode. When a file is
> opened, we simply set any deny bits in that mode that were specified in
the
> OPEN call. We can then use that unified deny mode to do a simple check to
> see whether there are any conflicts without needing to walk the entire
> stateid list.
> 
> The only time we'll need to walk the entire list of stateids is when a
stateid
> that has a deny mode on it is being released, or one is having its deny
mode
> downgraded. In that case, we must walk the entire list and recalculate the
> fi_share_deny field. Since deny modes are pretty rare today, this should
be
> very rare under normal workloads.

What we do in Ganesha to avoid walking the list of stateids on release is
maintain the effective deny (and access) mode not at bits, but as a counter
for each bit. Thus, to remove a SHARE_ACCESS_READ | SHARE_DENY_WRITE, you
decrement the counts for access_read and deny_write.

Frank



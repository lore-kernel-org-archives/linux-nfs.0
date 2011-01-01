Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:29784 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750851Ab1AAFoh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Jan 2011 00:44:37 -0500
Date: 1 Jan 2011 00:44:35 -0500
Message-ID: <20110101054435.29395.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: linux@horizon.com, Trond.Myklebust@netapp.com
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
In-Reply-To: <1293844690.22964.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

>> 1) Look again; it's O(1) work per entry, or O(n) work for an n-entry
>>    directory.  And O(1) space.  With very small constant factors,

> Yes. I was thinking about it this morning (after coffee).

Thank you for the second look.

> One variant on those algorithms that might make sense here is to save
> the current cookie each time we see that the result of a cookie search
> is a filp->f_pos offset < the current filp->f_pos offset. That means we
> will in general only detect the loop after going through an entire
> cycle, but that should be sufficient...

All of these low-overhead algorithms can take a couple of loop iterations
before they detect it; their job is to achieve a reasonably low constant
factor in time using O(1) space.

The worst case for the power-of-two algorithm is when the loop is n = 2^k+1
items long.  When you get to item 2^(k+1), you'll be comparing to item
2^k, which is a mismatch.  Then you'll save the cookie from 2^(k+1)
and have to go to 2^(k+1) + 2^k + 1, or about 3*n, before detecting
it.

I don't consider this a problem, because it wastes a few seconds of
computer time, to be followed by wasting a few hours trying to pass
a bug report upstream about the broken NFS server...

I don't quite follow how your proposed variant works.  Pardon my ignorance
of NFS, but is the f->pos something that comes from the server, or
something that is synthesized locally?  Obviously, if you keep a record
of all the server cookies, you can detect loops quite easily.

If it comes from the server, there's a risk that there might be two
backward jumps in the cycle, and thus you'll never notice it.


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49352 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750808Ab1AABSM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Dec 2010 20:18:12 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: George Spelvin <linux@horizon.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
In-Reply-To: <20110101010349.12974.qmail@science.horizon.com>
References: <20110101010349.12974.qmail@science.horizon.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 31 Dec 2010 20:18:10 -0500
Message-ID: <1293844690.22964.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-12-31 at 20:03 -0500, George Spelvin wrote: 
> > ...and your point would be that an exponentially increasing addition to
> > the existing number of tests is an acceptable tradeoff in a situation
> > where the >99.999999999999999% case is that of sane servers with no
> > looping? I don't think so...
> 
> 1) Look again; it's O(1) work per entry, or O(n) work for an n-entry
>    directory.  And O(1) space.  With very small constant factors, and
>    very little code.  The only thing exponentially increasing is the
>    interval at which you save the current cookie for future comparison.
> 2) You said it *was* a problem, so it seemed worth presenting a
>    practical solution.  If you don't think it's worth it, I'm not
>    going to disagree.  But it's not impossible, or even difficult.

Yes. I was thinking about it this morning (after coffee).

One variant on those algorithms that might make sense here is to save
the current cookie each time we see that the result of a cookie search
is a filp->f_pos offset < the current filp->f_pos offset. That means we
will in general only detect the loop after going through an entire
cycle, but that should be sufficient...

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


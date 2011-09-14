Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36483 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755922Ab1INVex (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 17:34:53 -0400
Date: Wed, 14 Sep 2011 17:34:51 -0400
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: Tim <supertimothy@web.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsv4 and gracetime / leasetime grace_period
Message-ID: <20110914213451.GA7109@fieldses.org>
References: <000801cc71f9$9cc45650$d64d02f0$@web.de>
 <20110913124440.GA22118@fieldses.org>
 <4E6FE4D1.20209@web.de>
 <20110914023709.GA28357@fieldses.org>
 <000001cc72a7$73151c50$593f54f0$@web.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <000001cc72a7$73151c50$593f54f0$@web.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 14, 2011 at 08:27:59AM +0200, Tim wrote:
> >> /proc/sys/fs/nfs/nlm_grace_period
> >> This is the part I don't understand what it is for. I read it has to 
> >> be shrunk too (I set it to 10 - which works). Standard value is 0.
> 
> > NLM (used with NFSv2/v3) works a little differently: instead of the clients polling at regular intervals, the server calls back to the clients to notify them that it has rebooted.  But there's still this grace period, which is the length of time the NLM server waits for the clients to act on the notifications by sending lock reclaims.
> 
> > It affects v4 as well, because the v4 server can't end its grace period before the NLM server does: if it did, v4 clients could rush in and start doing new locks before v2/v3 clients had the chance to reclaim all of theirs.
> 
> So if I only use NFSv4, I can set this to 1 second? Or would 0 be better?

Should be safe.  (Without looking at the code I don't remember if 0 is
allowed or has some special meaning.)

Some day we should start automatically turning off v2/v3-only stuff in
the v4-only case, it just hasn't been a priority yet.

--b.

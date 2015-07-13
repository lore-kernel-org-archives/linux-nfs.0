Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:58629 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbbGMGCp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 02:02:45 -0400
Date: Mon, 13 Jul 2015 07:02:40 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150713060240.GO17109@ZenIV.linux.org.uk>
References: <55A11010.6050005@gmail.com>
 <55A111A8.2040701@gmail.com>
 <20150713133934.6a4ef77d@noble>
 <20150713040258.GM17109@ZenIV.linux.org.uk>
 <20150713151910.0f493f49@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150713151910.0f493f49@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2015 at 03:19:10PM +1000, NeilBrown wrote:
> > Hell, no.  Intended use is to have ->kill() free the damn thing, period.
> 
> It is not possible to revise that intention?
> The apparent purpose of pin_kill() is to wait until the thing is freed,
> or to trigger that freeing itself.  Why not do both: trigger then wait?

Huh?  The first to come calls ->kill(); anybody coming between that and
pin_remove() done by ->kill() waits until pin_remove() is called and
buggers off.

> Given that all current uses have ->kill() call pin_remove, and as
> pin_remove sets ->done to 1, and as the patch makes no change to
> behaviour when ->kill() completes with ->done set to 1, I don't see how
> it can break anything.
> 'rcu' ensures that it is still save to examine p->done, and it will be
> '1'.

RCU ensures no such thing.  Where's the rcu_read_lock() opening the
RCU-critical area you need?

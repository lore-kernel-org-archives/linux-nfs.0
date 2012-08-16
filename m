Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46029 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932107Ab2HPTKU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Aug 2012 15:10:20 -0400
Date: Thu, 16 Aug 2012 15:10:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: "ZUIDAM, Hans" <Hans.Zuidam@philips.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "DE WITTE, PETER" <PETER.DE.WITTE@philips.com>
Subject: Re: Linux NFS and cached properties
Message-ID: <20120816191018.GA4385@fieldses.org>
References: <D307B3AC0BCD4C419E6B8FA6A2720A9C0C3B2F@011-DB3MPN1-001.MGDPHG.emi.philips.com>
 <20120724143748.GC8570@fieldses.org>
 <D307B3AC0BCD4C419E6B8FA6A2720A9C18ABBA@011-DB3MPN1-001.MGDPHG.emi.philips.com>
 <20120726223607.GA28982@fieldses.org>
 <20120731150801.0a4b557b@notabene.brown>
 <20120731122546.GA26737@fieldses.org>
 <20120802100405.4dfc3169@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120802100405.4dfc3169@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 02, 2012 at 10:04:05AM +1000, NeilBrown wrote:
> I never liked that fact that stopping the last thread did something extra.
> So when I added the ability to control the number of threads via sysfs I made

(You meant nfsd, not sysfs, right?  Or is there some interface I'm
overlooking?)

> sure that it *only* controlled the number of threads.  However I kept the
> legacy behaviour that sending SIGKILL to the nfsd threads would also unexport
> things.  Obviously I should have documented this better.
> 
> The more I think out it, the more I'd really like to go back to that.  It
> really is the *right* thing to do.
...
> > > 1/ iterate through all no-sleeping threads setting a flag an increasing a
> > > counter.
> > > 2/ when a thread completes current request, if test_and_clear the flag, it
> > > atomic_dec_and_test the counter and then wakes up some wait_queue_head.
> > > 3/ 'flush'ing thread waits on the waut_queue_head for the counter to be 0.
> > > 
> > > If you don't hate it I could possibly even provide some code.

By the way, are you still looking into one of those approaches?

--b.

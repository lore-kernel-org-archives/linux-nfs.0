Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52610 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S970385AbdDTPQ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Apr 2017 11:16:26 -0400
Date: Thu, 20 Apr 2017 11:16:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
Message-ID: <20170420151625.GA4782@fieldses.org>
References: <20170414150440.GA5362@fieldses.org>
 <20170414150940.GB5362@fieldses.org>
 <87h91mtvdb.fsf@notabene.neil.brown.name>
 <20170418171351.GF6208@fieldses.org>
 <878tmxtfne.fsf@notabene.neil.brown.name>
 <20170419004405.GA13002@fieldses.org>
 <87y3uvsxp5.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87y3uvsxp5.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 20, 2017 at 10:57:10AM +1000, NeilBrown wrote:
> I realise NFSv4 compounds don't have that limitation.
> I wondered what code in the NFSv4 server ensures that we don't try to use
> more memory than was allocated.
> 
> I notice lots of calls to xdr_reserve_space() in nfs4xdr.c.  Many of them
> trigger nfserr_resource when xdr_reserve_space() returns NULL.
> But not all.
> nfsd4_encode_readv() just pops up a warning.  Once.  Then will
> (eventually) de-reference the NULL pointer and crash.
> So presumably it really cannot happen (should be a BUG_ON anyway)?
> So why can this not happen?
> I see that nfsd4_encode_read() limits the size of the read to
>   xdr->buf->buflen - xdr->buf->len
> and nfsd4_encode_readdir() does a similar thing when computing
> bytes_left.
> 
> So, it is more careful about using the allocated pages than v2/3 is.

Yes.  The v4 code was written from the start with overflow checks
preceding any encode or decode.  And I tried to think this all through
carefully when I rewrote the encoding side a few years ago.  But I don't
think that really got much review, and test coverage is poor (a big
thanks here to the synpsys people for their fuzzing work), so additional
skeptical eyes are welcomed....

There's a lot of tricky hand-written code here handling data from the
network.  Every now and then somebody brings up the idea of trying to
autogenerate it, as is traditionally done for rpc programs.  No idea how
practical that is.

--b.

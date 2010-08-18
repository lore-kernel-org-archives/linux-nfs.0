Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45008 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211Ab0HRSVI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 14:21:08 -0400
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: David Woodhouse <dwmw2@infradead.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Patrick J. LoPresti" <lopresti@gmail.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
In-Reply-To: <20100817182920.GD18161@basil.fritz.box>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	 <87aaolwar8.fsf@basil.nowhere.org> <20100817174134.GA23176@fieldses.org>
	 <20100817182920.GD18161@basil.fritz.box>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 18 Aug 2010 19:20:58 +0100
Message-ID: <1282155658.13405.36.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-08-17 at 20:29 +0200, Andi Kleen wrote:
> 
> >       - Increment mtime by a nanosecond when necessary.  
> 
> You cannot be more precise than the backing file system: this causes
> non monotonity when the inodes are flushed (has happened in the past)

Um, can't you? You can't *store* timestamps which are more precise, but
they can be in cache can't they?

And since you're not going to drop it from cache and bring it back in
again within 4ms, that ought to suffice?

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation


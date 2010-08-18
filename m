Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51090 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753332Ab0HRSx6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 14:53:58 -0400
Date: Wed, 18 Aug 2010 20:53:54 +0200
From: Andi Kleen <andi@firstfloor.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, "J. Bruce Fields" <bfields@fieldses.org>,
        "Patrick J. LoPresti" <lopresti@gmail.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100818185354.GB6567@basil.fritz.box>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
 <87aaolwar8.fsf@basil.nowhere.org>
 <20100817174134.GA23176@fieldses.org>
 <20100817182920.GD18161@basil.fritz.box>
 <1282155658.13405.36.camel@localhost>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1282155658.13405.36.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 18, 2010 at 07:20:58PM +0100, David Woodhouse wrote:
> On Tue, 2010-08-17 at 20:29 +0200, Andi Kleen wrote:
> > 
> > >       - Increment mtime by a nanosecond when necessary.  
> > 
> > You cannot be more precise than the backing file system: this causes
> > non monotonity when the inodes are flushed (has happened in the past)
> 
> Um, can't you? You can't *store* timestamps which are more precise, but
> they can be in cache can't they?

No you can't. The initial implementation did that and it broke someone's
make. After that the VFS was fixed to never be precise than the backing
file system.

-Andi

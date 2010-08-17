Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:44152 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933111Ab0HQS31 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 14:29:27 -0400
Date: Tue, 17 Aug 2010 20:29:20 +0200
From: Andi Kleen <andi@firstfloor.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andi Kleen <andi@firstfloor.org>,
        "Patrick J. LoPresti" <lopresti@gmail.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100817182920.GD18161@basil.fritz.box>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
 <87aaolwar8.fsf@basil.nowhere.org>
 <20100817174134.GA23176@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100817174134.GA23176@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> OK, so that leaves us with the race, even on newer filesystems:
> 
> 	1. File is modified, mtime updated
> 	2. Client fetches mtime to revalidate cache
> 	3. File is modified again, mtime updated
> 	4. Client fetches new mtime to revalidate cache

You'll always have a race window with time, the only way around
that would be a version number.
> 	- Tell everyone to use NFSv4 (and make sure we have
> 	  changeattr/i_version working correctly).
> 	- Use a finer-grained time source.  (I believe you when you say
> 	  the TSC is too slow, but maybe we should run some tests to
> 	  make sure.)

It depends on the CPU too.

> 	- Increment mtime by a nanosecond when necessary.  

You cannot be more precise than the backing file system: this causes
non monotonity when the inodes are flushed (has happened in the past)

-Andi

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32007 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756701Ab1JDQCK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Oct 2011 12:02:10 -0400
Date: Tue, 4 Oct 2011 12:02:07 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] nfsd4: construct stateid from clientid and counter
Message-ID: <20111004160207.GA13557@pad.fieldses.org>
References: <20110919131415.GB32498@fieldses.org>
 <1316438143-1057-4-git-send-email-bfields@redhat.com>
 <4E89CA1C.4050107@tonian.com>
 <20111003145749.GB5524@pad.fieldses.org>
 <4E89D114.1020109@tonian.com>
 <20111003153821.GC5524@pad.fieldses.org>
 <4E8B2BC6.6020209@tonian.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E8B2BC6.6020209@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 04, 2011 at 05:52:38PM +0200, Benny Halevy wrote:
> OK, I'm going to use the common hash table also for the layout state
> which will have to use the same encoding linage.
> 
> It's a non-trivial rewrite of the layout state mechanisms but I
> it seems to simplify the code overall and will be more efficient
> in terms of lookup complexity (hash table vs. linear list)

Note later patches change the stateid lookup a little further, to
per-client lookup based on the "idr" code.  (I'm not actually sure what
idr uses underneath--looks like some kind of radix tree from a quick
check.)

I think the changes should all work for layout stateid's too, but let me
know if you run into any problems.

> I'm pretty hosed right now but I'd like to finish this
> before the Bakeathon so we can test the result there.

Great, thanks for keeping that code alive.  I won't be able to make the
bakeathon but please bug me and I'll make a special effort to be
responsive to bugs reported from the bakeathon as I know you'll have
limited testing time....

--b.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60876 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756359AbbKEWDq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Nov 2015 17:03:46 -0500
Date: Thu, 5 Nov 2015 17:03:46 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, jlayton@poochiereds.net
Subject: Re: [PATCH RFCv2] nfsd: fix race with open / open upgrade stateids
Message-ID: <20151105220346.GK9210@fieldses.org>
References: <1446657225-72903-1-git-send-email-aweits@rit.edu>
 <20151105212108.GH9210@fieldses.org>
 <m2a8qsru1m.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m2a8qsru1m.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 05, 2015 at 04:54:45PM -0500, Andrew W Elble wrote:
> 
> > Is there some lock imbalance?:
> 
> Hmmmm, I'll have to poke at that a bit.
> 
> > When you send a v2 patch, would you mind also describing what's changed?
> > If you stick the description here (between the --- and the diff), it'll
> > be discarded when git applies the patch (which is what we want).
> 
> Ah. In this case, v1 missed unlocking the rwsem if nfs4_upgrade_open()
> returned status.

OK.  Just to make sure, I checked again, and I was indeed testing with
your v2 (on top of some patches of my own which I'm fairly certain
weren't the cause, but I'll double check that as well).

--b.

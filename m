Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57882 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752582AbaGJQU2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2014 12:20:28 -0400
Date: Thu, 10 Jul 2014 12:20:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 015/100] nfsd: clean up reset_union_bmap_deny
Message-ID: <20140710162019.GG26851@fieldses.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-16-git-send-email-jlayton@primarydata.com>
 <20140710103100.GA6935@infradead.org>
 <20140710081912.4af7c35b@tlielax.poochiereds.net>
 <20140710131650.GA6806@infradead.org>
 <20140710092101.28558ab4@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140710092101.28558ab4@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 09:21:01AM -0400, Jeff Layton wrote:
> On Thu, 10 Jul 2014 06:16:50 -0700
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > Ok, feel free do drop my comments re the access/deny bitmap.  I don't
> > really think this is worth it to avoid the small false positive to
> > allow downgrading if a different open owner had a r/o or w/o open, but
> > it's probably indeed way to much churn for this series to do anything
> > about it.
> > 
> 
> Ok, thanks.
> 
> I agree that having to track this is a little ridiculous. No real client
> really cares about that, but there are some pynfs tests that will fail
> if we remove it altogether. I broke it a couple of years ago and Bruce
> dinged me on it, so I'm inclined not to change it here.

Looking back at the spec again, that server behavior is a SHOULD, but
I'm not sure why.

I suppose it's just an attempt to keep clients to the stricter behavior
in case some other server implementation requires it.  It seems like a
low priority, so if it makes your life easier, we can ditch it.

--b.

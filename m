Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:62694 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933927AbaGPO21 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 10:28:27 -0400
Received: by mail-qa0-f41.google.com with SMTP id j7so774532qaq.0
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 07:28:26 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 16 Jul 2014 10:28:24 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/7] nfsd: Ensure stateids remain unique until they are
 freed
Message-ID: <20140716102824.27eeb209@tlielax.poochiereds.net>
In-Reply-To: <20140716134945.GA11961@infradead.org>
References: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
	<1405420669-4030-3-git-send-email-jlayton@primarydata.com>
	<20140715171547.GA5269@infradead.org>
	<20140716081738.05ce6d92@tlielax.poochiereds.net>
	<20140716134945.GA11961@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Jul 2014 06:49:45 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Jul 16, 2014 at 08:17:38AM -0400, Jeff Layton wrote:
> > The problem with keeping them in the caller is that it defeats the main
> > purpose of the patch. The idea here is to make sure that we keep the
> > stateids in the IDR tree for as long as possible to help ensure
> > uniqueness. If we keep it in the caller, we're still removing the stateids
> > from the IDR hash earlier than we should, and that's a larger potential
> > for collisions.
> 
> I don't understand how that has anything to do with doing the call
> in either nfs4_free_stid or it's two caller.  For the open and lock
> stateids nothing changes in either case, and for delegations we
> move from destroy_(revoked_)delegation to the final put in
> nfs4_put_delegation for both variants.  While I'd normally prefer
> what you do in the patch it just seems like churn with the further
> changes.
> 

Ahh ok. I misunderstood what you were suggesting. Moving it into the
actual callers of nfs4_free_stid is fine.

Unfortunately, that creates a pile of merge conflicts in the later
patches. I'll just go ahead and change that and resend all of the
delegation patches that Bruce hasn't merged yet. Stay tuned...

-- 
Jeff Layton <jlayton@primarydata.com>

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:36698 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965079AbbLHPqP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2015 10:46:15 -0500
Received: by qgcc31 with SMTP id c31so21592079qgc.3
        for <linux-nfs@vger.kernel.org>; Tue, 08 Dec 2015 07:46:14 -0800 (PST)
Date: Tue, 8 Dec 2015 10:46:10 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@lst.de>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [RFC PATCH 2/2] nfsd: give up on CB_LAYOUTRECALLs after two
 lease periods
Message-ID: <20151208104610.6e3eae3f@tlielax.poochiereds.net>
In-Reply-To: <20151208152123.GB4035@lst.de>
References: <1449577428-13181-1-git-send-email-jeff.layton@primarydata.com>
	<1449577428-13181-3-git-send-email-jeff.layton@primarydata.com>
	<20151208152123.GB4035@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 8 Dec 2015 16:21:23 +0100
Christoph Hellwig <hch@lst.de> wrote:

> On Tue, Dec 08, 2015 at 07:23:48AM -0500, Jeff Layton wrote:
> > Have the CB_LAYOUTRECALL code treat NFS4_OK and NFS4ERR_DELAY returns
> > equivalently. Change the code to periodically resend CB_LAYOUTRECALLS
> > until the ls_layouts list is empty or the client returns a different
> > error code.
> > 
> > If we go for two lease periods without the list being emptied or the
> > client sending a hard error, then we give up and clean out the list
> > anyway.
> 
> This looks reasonable to me, but I'll need to actually test it
> before giving an ACK.
> 

Please do, I don't have a good way to test this at the moment...

> Btw, it seems like the delegation and layoutrecall code would benefit
> from some more code sharing for timeouts.  For example delegation
> returns currently don't support NFS4ERR_DELAY at all.

Yes...

I also wonder -- are we handling revoked layouts correctly? Shouldn't
we be handling revoked layouts like we would a revoked delegation? Stop
allowing the stateid to be used and morph it appropriately so that a
TEST_STATEID against it gives you an error?
 
Right now, it doesn't look like TEST_STATEID is set up to handle layout
stateids at all so they all get back NFS4ERR_BAD_STATEID.

-- 
Jeff Layton <jlayton@poochiereds.net>
